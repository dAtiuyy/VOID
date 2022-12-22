package kabam.rotmg.messaging.impl
{
   import com.company.assembleegameclient.game.AGameSprite;
   import com.company.assembleegameclient.game.events.GuildResultEvent;
   import com.company.assembleegameclient.game.events.NameResultEvent;
   import com.company.assembleegameclient.game.events.ReconnectEvent;
   import com.company.assembleegameclient.map.AbstractMap;
   import com.company.assembleegameclient.map.GroundLibrary;
   import com.company.assembleegameclient.map.mapoverlay.CharacterStatusText;
   import com.company.assembleegameclient.objects.Container;
   import com.company.assembleegameclient.objects.FlashDescription;
   import com.company.assembleegameclient.objects.GameObject;
   import com.company.assembleegameclient.objects.Merchant;
   import com.company.assembleegameclient.objects.NameChanger;
   import com.company.assembleegameclient.objects.ObjectLibrary;
   import com.company.assembleegameclient.objects.ObjectProperties;
   import com.company.assembleegameclient.objects.Pet;
   import com.company.assembleegameclient.objects.Player;
   import com.company.assembleegameclient.objects.Portal;
   import com.company.assembleegameclient.objects.Projectile;
   import com.company.assembleegameclient.objects.ProjectileProperties;
   import com.company.assembleegameclient.objects.SellableObject;
   import com.company.assembleegameclient.objects.particles.AOEEffect;
   import com.company.assembleegameclient.objects.particles.BurstEffect;
   import com.company.assembleegameclient.objects.particles.CollapseEffect;
   import com.company.assembleegameclient.objects.particles.ConeBlastEffect;
   import com.company.assembleegameclient.objects.particles.FlowEffect;
   import com.company.assembleegameclient.objects.particles.HealEffect;
   import com.company.assembleegameclient.objects.particles.LightningEffect;
   import com.company.assembleegameclient.objects.particles.LineEffect;
   import com.company.assembleegameclient.objects.particles.NovaEffect;
   import com.company.assembleegameclient.objects.particles.ParticleEffect;
   import com.company.assembleegameclient.objects.particles.PoisonEffect;
   import com.company.assembleegameclient.objects.particles.RingEffect;
   import com.company.assembleegameclient.objects.particles.RisingFuryEffect;
   import com.company.assembleegameclient.objects.particles.ShockeeEffect;
   import com.company.assembleegameclient.objects.particles.ShockerEffect;
   import com.company.assembleegameclient.objects.particles.StreamEffect;
   import com.company.assembleegameclient.objects.particles.TeleportEffect;
   import com.company.assembleegameclient.objects.particles.ThrowEffect;
   import com.company.assembleegameclient.objects.thrown.ThrowProjectileEffect;
   import com.company.assembleegameclient.parameters.Parameters;
   import com.company.assembleegameclient.sound.SoundEffectLibrary;
   import com.company.assembleegameclient.ui.PicView;
   import com.company.assembleegameclient.ui.dialogs.Dialog;
   import com.company.assembleegameclient.ui.dialogs.NotEnoughFameDialog;
   import com.company.assembleegameclient.ui.panels.GuildInvitePanel;
   import com.company.assembleegameclient.ui.panels.TradeRequestPanel;
   import com.company.assembleegameclient.util.ConditionEffect;
   import com.company.assembleegameclient.util.Currency;
   import com.company.assembleegameclient.util.FreeList;
   import com.company.util.MoreStringUtil;
   import com.company.util.Random;
   import com.hurlant.crypto.Crypto;
   import com.hurlant.crypto.rsa.RSAKey;
   import com.hurlant.crypto.symmetric.ICipher;
   import com.hurlant.util.Base64;
   import com.hurlant.util.der.PEM;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.net.FileReference;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import kabam.lib.net.api.MessageMap;
   import kabam.lib.net.api.MessageProvider;
   import kabam.lib.net.impl.Message;
   import kabam.lib.net.impl.SocketServer;
   import kabam.rotmg.account.core.Account;
   import kabam.rotmg.arena.control.ArenaDeathSignal;
   import kabam.rotmg.arena.control.ImminentArenaWaveSignal;
   import kabam.rotmg.arena.model.CurrentArenaRunModel;
   import kabam.rotmg.arena.view.BattleSummaryDialog;
   import kabam.rotmg.arena.view.ContinueOrQuitDialog;
   import kabam.rotmg.chat.model.ChatMessage;
   import kabam.rotmg.classes.model.CharacterClass;
   import kabam.rotmg.classes.model.CharacterSkin;
   import kabam.rotmg.classes.model.CharacterSkinState;
   import kabam.rotmg.classes.model.ClassesModel;
   import kabam.rotmg.constants.GeneralConstants;
   import kabam.rotmg.constants.ItemConstants;
   import kabam.rotmg.core.StaticInjectorContext;
   import kabam.rotmg.death.control.HandleDeathSignal;
   import kabam.rotmg.death.control.ZombifySignal;
   import kabam.rotmg.dialogs.control.CloseDialogsSignal;
   import kabam.rotmg.dialogs.control.OpenDialogSignal;
   import kabam.rotmg.friends.model.FriendModel;
   import kabam.rotmg.game.focus.control.SetGameFocusSignal;
   import kabam.rotmg.game.model.GameModel;
   import kabam.rotmg.game.model.PotionInventoryModel;
   import kabam.rotmg.game.signals.AddSpeechBalloonSignal;
   import kabam.rotmg.game.signals.AddTextLineSignal;
   import kabam.rotmg.game.signals.GiftStatusUpdateSignal;
   import kabam.rotmg.game.view.components.QueuedStatusText;
   import kabam.rotmg.maploading.signals.ChangeMapSignal;
   import kabam.rotmg.maploading.signals.HideMapLoadingSignal;
   import kabam.rotmg.messaging.impl.data.GroundTileData;
   import kabam.rotmg.messaging.impl.data.ObjectData;
   import kabam.rotmg.messaging.impl.data.ObjectStatusData;
   import kabam.rotmg.messaging.impl.data.StatData;
   import kabam.rotmg.messaging.impl.incoming.AccountList;
   import kabam.rotmg.messaging.impl.incoming.AllyShoot;
   import kabam.rotmg.messaging.impl.incoming.Aoe;
   import kabam.rotmg.messaging.impl.incoming.BuyResult;
   import kabam.rotmg.messaging.impl.incoming.ClientStat;
   import kabam.rotmg.messaging.impl.incoming.CreateSuccess;
   import kabam.rotmg.messaging.impl.incoming.Damage;
   import kabam.rotmg.messaging.impl.incoming.Death;
   import kabam.rotmg.messaging.impl.incoming.EnemyShoot;
   import kabam.rotmg.messaging.impl.incoming.EvolvedMessageHandler;
   import kabam.rotmg.messaging.impl.incoming.EvolvedPetMessage;
   import kabam.rotmg.messaging.impl.incoming.Failure;
   import kabam.rotmg.messaging.impl.incoming.File;
   import kabam.rotmg.messaging.impl.incoming.GlobalNotification;
   import kabam.rotmg.messaging.impl.incoming.Goto;
   import kabam.rotmg.messaging.impl.incoming.GuildResult;
   import kabam.rotmg.messaging.impl.incoming.InvResult;
   import kabam.rotmg.messaging.impl.incoming.InvitedToGuild;
   import kabam.rotmg.messaging.impl.incoming.MapInfo;
   import kabam.rotmg.messaging.impl.incoming.NameResult;
   import kabam.rotmg.messaging.impl.incoming.NewAbilityMessage;
   import kabam.rotmg.messaging.impl.incoming.NewTick;
   import kabam.rotmg.messaging.impl.incoming.Notification;
   import kabam.rotmg.messaging.impl.incoming.PasswordPrompt;
   import kabam.rotmg.messaging.impl.incoming.Pic;
   import kabam.rotmg.messaging.impl.incoming.Ping;
   import kabam.rotmg.messaging.impl.incoming.PlaySound;
   import kabam.rotmg.messaging.impl.incoming.QuestFetchResponse;
   import kabam.rotmg.messaging.impl.incoming.QuestObjId;
   import kabam.rotmg.messaging.impl.incoming.QuestRedeemResponse;
   import kabam.rotmg.messaging.impl.incoming.Reconnect;
   import kabam.rotmg.messaging.impl.incoming.ReskinUnlock;
   import kabam.rotmg.messaging.impl.incoming.ServerPlayerShoot;
   import kabam.rotmg.messaging.impl.incoming.ShowEffect;
   import kabam.rotmg.messaging.impl.incoming.TradeAccepted;
   import kabam.rotmg.messaging.impl.incoming.TradeChanged;
   import kabam.rotmg.messaging.impl.incoming.TradeDone;
   import kabam.rotmg.messaging.impl.incoming.TradeRequested;
   import kabam.rotmg.messaging.impl.incoming.TradeStart;
   import kabam.rotmg.messaging.impl.incoming.Update;
   import kabam.rotmg.messaging.impl.incoming.VerifyEmail;
   import kabam.rotmg.messaging.impl.incoming.arena.ArenaDeath;
   import kabam.rotmg.messaging.impl.incoming.arena.ImminentArenaWave;
   import kabam.rotmg.messaging.impl.incoming.pets.DeletePetMessage;
   import kabam.rotmg.messaging.impl.incoming.pets.HatchPetMessage;
   import kabam.rotmg.messaging.impl.outgoing.AcceptTrade;
   import kabam.rotmg.messaging.impl.outgoing.ActivePetUpdateRequest;
   import kabam.rotmg.messaging.impl.outgoing.AoeAck;
   import kabam.rotmg.messaging.impl.outgoing.Buy;
   import kabam.rotmg.messaging.impl.outgoing.CancelTrade;
   import kabam.rotmg.messaging.impl.outgoing.ChangeGuildRank;
   import kabam.rotmg.messaging.impl.outgoing.ChangeTrade;
   import kabam.rotmg.messaging.impl.outgoing.CheckCredits;
   import kabam.rotmg.messaging.impl.outgoing.ChooseName;
   import kabam.rotmg.messaging.impl.outgoing.Create;
   import kabam.rotmg.messaging.impl.outgoing.CreateGuild;
   import kabam.rotmg.messaging.impl.outgoing.EditAccountList;
   import kabam.rotmg.messaging.impl.outgoing.EnemyHit;
   import kabam.rotmg.messaging.impl.outgoing.Escape;
   import kabam.rotmg.messaging.impl.outgoing.GotoAck;
   import kabam.rotmg.messaging.impl.outgoing.GroundDamage;
   import kabam.rotmg.messaging.impl.outgoing.GuildInvite;
   import kabam.rotmg.messaging.impl.outgoing.GuildRemove;
   import kabam.rotmg.messaging.impl.outgoing.Hello;
   import kabam.rotmg.messaging.impl.outgoing.InvDrop;
   import kabam.rotmg.messaging.impl.outgoing.InvSwap;
   import kabam.rotmg.messaging.impl.outgoing.JoinGuild;
   import kabam.rotmg.messaging.impl.outgoing.Load;
   import kabam.rotmg.messaging.impl.outgoing.Move;
   import kabam.rotmg.messaging.impl.outgoing.OtherHit;
   import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;
   import kabam.rotmg.messaging.impl.outgoing.PlayerHit;
   import kabam.rotmg.messaging.impl.outgoing.PlayerShoot;
   import kabam.rotmg.messaging.impl.outgoing.PlayerText;
   import kabam.rotmg.messaging.impl.outgoing.Pong;
   import kabam.rotmg.messaging.impl.outgoing.RequestTrade;
   import kabam.rotmg.messaging.impl.outgoing.Reskin;
   import kabam.rotmg.messaging.impl.outgoing.SetCondition;
   import kabam.rotmg.messaging.impl.outgoing.ShootAck;
   import kabam.rotmg.messaging.impl.outgoing.SquareHit;
   import kabam.rotmg.messaging.impl.outgoing.Teleport;
   import kabam.rotmg.messaging.impl.outgoing.UseItem;
   import kabam.rotmg.messaging.impl.outgoing.UsePortal;
   import kabam.rotmg.messaging.impl.outgoing.arena.EnterArena;
   import kabam.rotmg.messaging.impl.outgoing.arena.QuestRedeem;
   import kabam.rotmg.minimap.control.UpdateGameObjectTileSignal;
   import kabam.rotmg.minimap.control.UpdateGroundTileSignal;
   import kabam.rotmg.minimap.model.UpdateGroundTileVO;
   import kabam.rotmg.pets.controller.DeletePetSignal;
   import kabam.rotmg.pets.controller.HatchPetSignal;
   import kabam.rotmg.pets.controller.NewAbilitySignal;
   import kabam.rotmg.pets.controller.PetFeedResultSignal;
   import kabam.rotmg.pets.controller.UpdateActivePet;
   import kabam.rotmg.pets.controller.UpdatePetYardSignal;
   import kabam.rotmg.pets.data.PetsModel;
   import kabam.rotmg.questrewards.controller.QuestFetchCompleteSignal;
   import kabam.rotmg.questrewards.controller.QuestRedeemCompleteSignal;
   import kabam.rotmg.servers.api.Server;
   import kabam.rotmg.text.model.TextKey;
   import kabam.rotmg.text.view.stringBuilder.LineBuilder;
   import kabam.rotmg.ui.model.Key;
   import kabam.rotmg.ui.model.UpdateGameObjectTileVO;
   import kabam.rotmg.ui.signals.ShowHideKeyUISignal;
   import kabam.rotmg.ui.signals.ShowKeySignal;
   import kabam.rotmg.ui.signals.UpdateBackpackTabSignal;
   import kabam.rotmg.ui.view.NotEnoughGoldDialog;
   import kabam.rotmg.ui.view.TitleView;
   import org.swiftsuspenders.Injector;
   import robotlegs.bender.framework.api.ILogger;
   
   public class GameServerConnectionConcrete extends GameServerConnection
   {
      
      private static const TO_MILLISECONDS:int = 1000;
       
      
      private var petUpdater:PetUpdater;
      
      private var messages:MessageProvider;
      
      public var playerId_:int = -1;
      
      private var player:Player;
      
      private var retryConnection_:Boolean = true;
      
      private var rand_:Random = null;
      
      private var giftChestUpdateSignal:GiftStatusUpdateSignal;
      
      private var death:Death;
      
      private var retryTimer_:Timer;
      
      private var delayBeforeReconnect:int = 2;
      
      private var addTextLine:AddTextLineSignal;
      
      private var addSpeechBalloon:AddSpeechBalloonSignal;
      
      private var updateGroundTileSignal:UpdateGroundTileSignal;
      
      private var updateGameObjectTileSignal:UpdateGameObjectTileSignal;
      
      private var logger:ILogger;
      
      private var handleDeath:HandleDeathSignal;
      
      private var zombify:ZombifySignal;
      
      private var setGameFocus:SetGameFocusSignal;
      
      private var updateBackpackTab:UpdateBackpackTabSignal;
      
      private var petFeedResult:PetFeedResultSignal;
      
      private var closeDialogs:CloseDialogsSignal;
      
      private var openDialog:OpenDialogSignal;
      
      private var arenaDeath:ArenaDeathSignal;
      
      private var imminentWave:ImminentArenaWaveSignal;
      
      private var questFetchComplete:QuestFetchCompleteSignal;
      
      private var questRedeemComplete:QuestRedeemCompleteSignal;
      
      private var currentArenaRun:CurrentArenaRunModel;
      
      private var classesModel:ClassesModel;
      
      private var injector:Injector;
      
      private var model:GameModel;
      
      private var updateActivePet:UpdateActivePet;
      
      private var petsModel:PetsModel;
      
      private var friendModel:FriendModel;
      
      public function GameServerConnectionConcrete(param1:AGameSprite, param2:Server, param3:int, param4:Boolean, param5:int, param6:int, param7:ByteArray, param8:String, param9:Boolean)
      {
         super();
         this.injector = StaticInjectorContext.getInjector();
         this.giftChestUpdateSignal = this.injector.getInstance(GiftStatusUpdateSignal);
         this.addTextLine = this.injector.getInstance(AddTextLineSignal);
         this.addSpeechBalloon = this.injector.getInstance(AddSpeechBalloonSignal);
         this.updateGroundTileSignal = this.injector.getInstance(UpdateGroundTileSignal);
         this.updateGameObjectTileSignal = this.injector.getInstance(UpdateGameObjectTileSignal);
         this.petFeedResult = this.injector.getInstance(PetFeedResultSignal);
         this.updateBackpackTab = StaticInjectorContext.getInjector().getInstance(UpdateBackpackTabSignal);
         this.updateActivePet = this.injector.getInstance(UpdateActivePet);
         this.petsModel = this.injector.getInstance(PetsModel);
         this.friendModel = this.injector.getInstance(FriendModel);
         this.closeDialogs = this.injector.getInstance(CloseDialogsSignal);
         changeMapSignal = this.injector.getInstance(ChangeMapSignal);
         this.openDialog = this.injector.getInstance(OpenDialogSignal);
         this.arenaDeath = this.injector.getInstance(ArenaDeathSignal);
         this.imminentWave = this.injector.getInstance(ImminentArenaWaveSignal);
         this.questFetchComplete = this.injector.getInstance(QuestFetchCompleteSignal);
         this.questRedeemComplete = this.injector.getInstance(QuestRedeemCompleteSignal);
         this.logger = this.injector.getInstance(ILogger);
         this.handleDeath = this.injector.getInstance(HandleDeathSignal);
         this.zombify = this.injector.getInstance(ZombifySignal);
         this.setGameFocus = this.injector.getInstance(SetGameFocusSignal);
         this.classesModel = this.injector.getInstance(ClassesModel);
         serverConnection = this.injector.getInstance(SocketServer);
         this.messages = this.injector.getInstance(MessageProvider);
         this.model = this.injector.getInstance(GameModel);
         this.currentArenaRun = this.injector.getInstance(CurrentArenaRunModel);
         gs_ = param1;
         server_ = param2;
         gameId_ = param3;
         createCharacter_ = param4;
         charId_ = param5;
         keyTime_ = param6;
         key_ = param7;
         mapJSON_ = param8;
         isFromArena_ = param9;
         this.friendModel.setCurrentServer(server_);
         this.getPetUpdater();
         instance = this;
      }
      
      private static function isStatPotion(param1:int) : Boolean
      {
         return param1 == 2591 || param1 == 5465 || param1 == 9064 || (param1 == 2592 || param1 == 5466 || param1 == 9065) || (param1 == 2593 || param1 == 5467 || param1 == 9066) || (param1 == 2612 || param1 == 5468 || param1 == 9067) || (param1 == 2613 || param1 == 5469 || param1 == 9068) || (param1 == 2636 || param1 == 5470 || param1 == 9069) || (param1 == 2793 || param1 == 5471 || param1 == 9070) || (param1 == 2794 || param1 == 5472 || param1 == 9071);
      }
      
      private function getPetUpdater() : void
      {
         this.injector.map(AGameSprite).toValue(gs_);
         this.petUpdater = this.injector.getInstance(PetUpdater);
         this.injector.unmap(AGameSprite);
      }
      
      override public function disconnect() : void
      {
         this.removeServerConnectionListeners();
         this.unmapMessages();
         serverConnection.disconnect();
      }
      
      private function removeServerConnectionListeners() : void
      {
         serverConnection.connected.remove(this.onConnected);
         serverConnection.closed.remove(this.onClosed);
         serverConnection.error.remove(this.onError);
      }
      
      override public function connect() : void
      {
         this.addServerConnectionListeners();
         this.mapMessages();
         var _loc1_:ChatMessage = new ChatMessage();
         _loc1_.name = Parameters.CLIENT_CHAT_NAME;
         _loc1_.text = TextKey.CHAT_CONNECTING_TO;
         _loc1_.tokens = {"serverName":server_.name};
         this.addTextLine.dispatch(_loc1_);
         serverConnection.connect(server_.address,server_.port);
      }
      
      public function addServerConnectionListeners() : void
      {
         serverConnection.connected.add(this.onConnected);
         serverConnection.closed.add(this.onClosed);
         serverConnection.error.add(this.onError);
      }
      
      public function mapMessages() : void
      {
         var _loc1_:MessageMap = this.injector.getInstance(MessageMap);
         _loc1_.map(CREATE).toMessage(Create);
         _loc1_.map(PLAYERSHOOT).toMessage(PlayerShoot);
         _loc1_.map(MOVE).toMessage(Move);
         _loc1_.map(PLAYERTEXT).toMessage(PlayerText);
         _loc1_.map(UPDATEACK).toMessage(Message);
         _loc1_.map(INVSWAP).toMessage(InvSwap);
         _loc1_.map(USEITEM).toMessage(UseItem);
         _loc1_.map(HELLO).toMessage(Hello);
         _loc1_.map(INVDROP).toMessage(InvDrop);
         _loc1_.map(PONG).toMessage(Pong);
         _loc1_.map(LOAD).toMessage(Load);
         _loc1_.map(SETCONDITION).toMessage(SetCondition);
         _loc1_.map(TELEPORT).toMessage(Teleport);
         _loc1_.map(USEPORTAL).toMessage(UsePortal);
         _loc1_.map(BUY).toMessage(Buy);
         _loc1_.map(PLAYERHIT).toMessage(PlayerHit);
         _loc1_.map(ENEMYHIT).toMessage(EnemyHit);
         _loc1_.map(AOEACK).toMessage(AoeAck);
         _loc1_.map(SHOOTACK).toMessage(ShootAck);
         _loc1_.map(OTHERHIT).toMessage(OtherHit);
         _loc1_.map(SQUAREHIT).toMessage(SquareHit);
         _loc1_.map(GOTOACK).toMessage(GotoAck);
         _loc1_.map(GROUNDDAMAGE).toMessage(GroundDamage);
         _loc1_.map(CHOOSENAME).toMessage(ChooseName);
         _loc1_.map(CREATEGUILD).toMessage(CreateGuild);
         _loc1_.map(GUILDREMOVE).toMessage(GuildRemove);
         _loc1_.map(GUILDINVITE).toMessage(GuildInvite);
         _loc1_.map(REQUESTTRADE).toMessage(RequestTrade);
         _loc1_.map(CHANGETRADE).toMessage(ChangeTrade);
         _loc1_.map(ACCEPTTRADE).toMessage(AcceptTrade);
         _loc1_.map(CANCELTRADE).toMessage(CancelTrade);
         _loc1_.map(CHECKCREDITS).toMessage(CheckCredits);
         _loc1_.map(ESCAPE).toMessage(Escape);
         _loc1_.map(JOINGUILD).toMessage(JoinGuild);
         _loc1_.map(CHANGEGUILDRANK).toMessage(ChangeGuildRank);
         _loc1_.map(EDITACCOUNTLIST).toMessage(EditAccountList);
         _loc1_.map(ACTIVE_PET_UPDATE_REQUEST).toMessage(ActivePetUpdateRequest);
         _loc1_.map(PETUPGRADEREQUEST).toMessage(PetUpgradeRequest);
         _loc1_.map(ENTER_ARENA).toMessage(EnterArena);
         _loc1_.map(ACCEPT_ARENA_DEATH).toMessage(OutgoingMessage);
         _loc1_.map(QUEST_FETCH_ASK).toMessage(OutgoingMessage);
         _loc1_.map(QUEST_REDEEM).toMessage(QuestRedeem);
         _loc1_.map(PET_CHANGE_FORM_MSG).toMessage(ReskinPet);
         _loc1_.map(FAILURE).toMessage(Failure).toMethod(this.onFailure);
         _loc1_.map(CREATE_SUCCESS).toMessage(CreateSuccess).toMethod(this.onCreateSuccess);
         _loc1_.map(SERVERPLAYERSHOOT).toMessage(ServerPlayerShoot).toMethod(this.onServerPlayerShoot);
         _loc1_.map(DAMAGE).toMessage(Damage).toMethod(this.onDamage);
         _loc1_.map(UPDATE).toMessage(Update).toMethod(this.onUpdate);
         _loc1_.map(NOTIFICATION).toMessage(Notification).toMethod(this.onNotification);
         _loc1_.map(GLOBAL_NOTIFICATION).toMessage(GlobalNotification).toMethod(this.onGlobalNotification);
         _loc1_.map(NEWTICK).toMessage(NewTick).toMethod(this.onNewTick);
         _loc1_.map(SHOWEFFECT).toMessage(ShowEffect).toMethod(this.onShowEffect);
         _loc1_.map(GOTO).toMessage(Goto).toMethod(this.onGoto);
         _loc1_.map(INVRESULT).toMessage(InvResult).toMethod(this.onInvResult);
         _loc1_.map(RECONNECT).toMessage(Reconnect).toMethod(this.onReconnect);
         _loc1_.map(PING).toMessage(Ping).toMethod(this.onPing);
         _loc1_.map(MAPINFO).toMessage(MapInfo).toMethod(this.onMapInfo);
         _loc1_.map(PIC).toMessage(Pic).toMethod(this.onPic);
         _loc1_.map(DEATH).toMessage(Death).toMethod(this.onDeath);
         _loc1_.map(BUYRESULT).toMessage(BuyResult).toMethod(this.onBuyResult);
         _loc1_.map(AOE).toMessage(Aoe).toMethod(this.onAoe);
         _loc1_.map(ACCOUNTLIST).toMessage(AccountList).toMethod(this.onAccountList);
         _loc1_.map(QUESTOBJID).toMessage(QuestObjId).toMethod(this.onQuestObjId);
         _loc1_.map(NAMERESULT).toMessage(NameResult).toMethod(this.onNameResult);
         _loc1_.map(GUILDRESULT).toMessage(GuildResult).toMethod(this.onGuildResult);
         _loc1_.map(ALLYSHOOT).toMessage(AllyShoot).toMethod(this.onAllyShoot);
         _loc1_.map(ENEMYSHOOT).toMessage(EnemyShoot).toMethod(this.onEnemyShoot);
         _loc1_.map(TRADEREQUESTED).toMessage(TradeRequested).toMethod(this.onTradeRequested);
         _loc1_.map(TRADESTART).toMessage(TradeStart).toMethod(this.onTradeStart);
         _loc1_.map(TRADECHANGED).toMessage(TradeChanged).toMethod(this.onTradeChanged);
         _loc1_.map(TRADEDONE).toMessage(TradeDone).toMethod(this.onTradeDone);
         _loc1_.map(TRADEACCEPTED).toMessage(TradeAccepted).toMethod(this.onTradeAccepted);
         _loc1_.map(CLIENTSTAT).toMessage(ClientStat).toMethod(this.onClientStat);
         _loc1_.map(FILE).toMessage(File).toMethod(this.onFile);
         _loc1_.map(INVITEDTOGUILD).toMessage(InvitedToGuild).toMethod(this.onInvitedToGuild);
         _loc1_.map(PLAYSOUND).toMessage(PlaySound).toMethod(this.onPlaySound);
         _loc1_.map(ACTIVEPETUPDATE).toMessage(ActivePet).toMethod(this.onActivePetUpdate);
         _loc1_.map(NEW_ABILITY).toMessage(NewAbilityMessage).toMethod(this.onNewAbility);
         _loc1_.map(PETYARDUPDATE).toMessage(PetYard).toMethod(this.onPetYardUpdate);
         _loc1_.map(EVOLVE_PET).toMessage(EvolvedPetMessage).toMethod(this.onEvolvedPet);
         _loc1_.map(DELETE_PET).toMessage(DeletePetMessage).toMethod(this.onDeletePet);
         _loc1_.map(HATCH_PET).toMessage(HatchPetMessage).toMethod(this.onHatchPet);
         _loc1_.map(IMMINENT_ARENA_WAVE).toMessage(ImminentArenaWave).toMethod(this.onImminentArenaWave);
         _loc1_.map(ARENA_DEATH).toMessage(ArenaDeath).toMethod(this.onArenaDeath);
         _loc1_.map(VERIFY_EMAIL).toMessage(VerifyEmail).toMethod(this.onVerifyEmail);
         _loc1_.map(RESKIN_UNLOCK).toMessage(ReskinUnlock).toMethod(this.onReskinUnlock);
         _loc1_.map(PASSWORD_PROMPT).toMessage(PasswordPrompt).toMethod(this.onPasswordPrompt);
         _loc1_.map(QUEST_FETCH_RESPONSE).toMessage(QuestFetchResponse).toMethod(this.onQuestFetchResponse);
         _loc1_.map(QUEST_REDEEM_RESPONSE).toMessage(QuestRedeemResponse).toMethod(this.onQuestRedeemResponse);
      }
      
      private function onHatchPet(param1:HatchPetMessage) : void
      {
         var _loc2_:HatchPetSignal = this.injector.getInstance(HatchPetSignal);
         _loc2_.dispatch(param1.petName,param1.petSkin);
      }
      
      private function onDeletePet(param1:DeletePetMessage) : void
      {
         var _loc2_:DeletePetSignal = this.injector.getInstance(DeletePetSignal);
         _loc2_.dispatch(param1.petID);
      }
      
      private function onNewAbility(param1:NewAbilityMessage) : void
      {
         var _loc2_:NewAbilitySignal = this.injector.getInstance(NewAbilitySignal);
         _loc2_.dispatch(param1.type);
      }
      
      private function onPetYardUpdate(param1:PetYard) : void
      {
         var _loc2_:UpdatePetYardSignal = StaticInjectorContext.getInjector().getInstance(UpdatePetYardSignal);
         _loc2_.dispatch(param1.type);
      }
      
      private function onEvolvedPet(param1:EvolvedPetMessage) : void
      {
         var _loc2_:EvolvedMessageHandler = this.injector.getInstance(EvolvedMessageHandler);
         _loc2_.handleMessage(param1);
      }
      
      private function onActivePetUpdate(param1:ActivePet) : void
      {
         this.updateActivePet.dispatch(param1.instanceID);
         var _loc2_:String = param1.instanceID > 0 ? this.petsModel.getPet(param1.instanceID).getName() : "";
         var _loc3_:String = param1.instanceID < 0 ? TextKey.PET_NOT_FOLLOWING : TextKey.PET_FOLLOWING;
         this.addTextLine.dispatch(ChatMessage.make(Parameters.SERVER_CHAT_NAME,_loc3_,-1,-1,"",false,{"petName":_loc2_}));
      }
      
      private function unmapMessages() : void
      {
         var _loc1_:MessageMap = this.injector.getInstance(MessageMap);
         _loc1_.unmap(CREATE);
         _loc1_.unmap(PLAYERSHOOT);
         _loc1_.unmap(MOVE);
         _loc1_.unmap(PLAYERTEXT);
         _loc1_.unmap(UPDATEACK);
         _loc1_.unmap(INVSWAP);
         _loc1_.unmap(USEITEM);
         _loc1_.unmap(HELLO);
         _loc1_.unmap(INVDROP);
         _loc1_.unmap(PONG);
         _loc1_.unmap(LOAD);
         _loc1_.unmap(SETCONDITION);
         _loc1_.unmap(TELEPORT);
         _loc1_.unmap(USEPORTAL);
         _loc1_.unmap(BUY);
         _loc1_.unmap(PLAYERHIT);
         _loc1_.unmap(ENEMYHIT);
         _loc1_.unmap(AOEACK);
         _loc1_.unmap(SHOOTACK);
         _loc1_.unmap(OTHERHIT);
         _loc1_.unmap(SQUAREHIT);
         _loc1_.unmap(GOTOACK);
         _loc1_.unmap(GROUNDDAMAGE);
         _loc1_.unmap(CHOOSENAME);
         _loc1_.unmap(CREATEGUILD);
         _loc1_.unmap(GUILDREMOVE);
         _loc1_.unmap(GUILDINVITE);
         _loc1_.unmap(REQUESTTRADE);
         _loc1_.unmap(CHANGETRADE);
         _loc1_.unmap(ACCEPTTRADE);
         _loc1_.unmap(CANCELTRADE);
         _loc1_.unmap(CHECKCREDITS);
         _loc1_.unmap(ESCAPE);
         _loc1_.unmap(JOINGUILD);
         _loc1_.unmap(CHANGEGUILDRANK);
         _loc1_.unmap(EDITACCOUNTLIST);
         _loc1_.unmap(FAILURE);
         _loc1_.unmap(CREATE_SUCCESS);
         _loc1_.unmap(SERVERPLAYERSHOOT);
         _loc1_.unmap(DAMAGE);
         _loc1_.unmap(UPDATE);
         _loc1_.unmap(NOTIFICATION);
         _loc1_.unmap(GLOBAL_NOTIFICATION);
         _loc1_.unmap(NEWTICK);
         _loc1_.unmap(SHOWEFFECT);
         _loc1_.unmap(GOTO);
         _loc1_.unmap(INVRESULT);
         _loc1_.unmap(RECONNECT);
         _loc1_.unmap(PING);
         _loc1_.unmap(MAPINFO);
         _loc1_.unmap(PIC);
         _loc1_.unmap(DEATH);
         _loc1_.unmap(BUYRESULT);
         _loc1_.unmap(AOE);
         _loc1_.unmap(ACCOUNTLIST);
         _loc1_.unmap(QUESTOBJID);
         _loc1_.unmap(NAMERESULT);
         _loc1_.unmap(GUILDRESULT);
         _loc1_.unmap(ALLYSHOOT);
         _loc1_.unmap(ENEMYSHOOT);
         _loc1_.unmap(TRADEREQUESTED);
         _loc1_.unmap(TRADESTART);
         _loc1_.unmap(TRADECHANGED);
         _loc1_.unmap(TRADEDONE);
         _loc1_.unmap(TRADEACCEPTED);
         _loc1_.unmap(CLIENTSTAT);
         _loc1_.unmap(FILE);
         _loc1_.unmap(INVITEDTOGUILD);
         _loc1_.unmap(PLAYSOUND);
      }
      
      private function encryptConnection() : void
      {
         var _loc1_:ICipher = null;
         var _loc2_:ICipher = null;
         if(Parameters.ENABLE_ENCRYPTION)
         {
            _loc1_ = Crypto.getCipher("rc4",MoreStringUtil.hexStringToByteArray("311f80691451c71d09a13a2a6e"));
            _loc2_ = Crypto.getCipher("rc4",MoreStringUtil.hexStringToByteArray("72c5583cafb6818995cdd74b80"));
            serverConnection.setOutgoingCipher(_loc1_);
            serverConnection.setIncomingCipher(_loc2_);
         }
      }
      
      override public function getNextDamage(param1:uint, param2:uint) : uint
      {
         return this.rand_.nextIntRange(param1,param2);
      }
      
      override public function enableJitterWatcher() : void
      {
         if(jitterWatcher_ == null)
         {
            jitterWatcher_ = new JitterWatcher();
         }
      }
      
      override public function disableJitterWatcher() : void
      {
         if(jitterWatcher_ != null)
         {
            jitterWatcher_ = null;
         }
      }
      
      private function create() : void
      {
         var _loc1_:CharacterClass = this.classesModel.getSelected();
         var _loc2_:Create = this.messages.require(CREATE) as Create;
         _loc2_.classType = _loc1_.id;
         _loc2_.skinType = _loc1_.skins.getSelectedSkin().id;
         serverConnection.sendMessage(_loc2_);
      }
      
      private function load() : void
      {
         var _loc1_:Load = this.messages.require(LOAD) as Load;
         _loc1_.charId_ = charId_;
         _loc1_.isFromArena_ = isFromArena_;
         serverConnection.sendMessage(_loc1_);
         if(isFromArena_)
         {
            this.openDialog.dispatch(new BattleSummaryDialog());
         }
      }
      
      override public function playerShoot(param1:int, param2:Projectile) : void
      {
         var _loc3_:PlayerShoot = this.messages.require(PLAYERSHOOT) as PlayerShoot;
         _loc3_.time_ = param1;
         _loc3_.bulletId_ = param2.bulletId_;
         _loc3_.containerType_ = param2.containerType_;
         _loc3_.startingPos_.x_ = param2.x_;
         _loc3_.startingPos_.y_ = param2.y_;
         _loc3_.angle_ = param2.angle_;
         serverConnection.sendMessage(_loc3_);
      }
      
      override public function playerHit(param1:int, param2:int) : void
      {
         var _loc3_:PlayerHit = this.messages.require(PLAYERHIT) as PlayerHit;
         _loc3_.bulletId_ = param1;
         _loc3_.objectId_ = param2;
         if(!Parameters.data_.GodMode)
         {
            serverConnection.sendMessage(_loc3_);
         }
      }
      
      override public function enemyHit(param1:int, param2:int, param3:int, param4:Boolean) : void
      {
         var _loc5_:EnemyHit = this.messages.require(ENEMYHIT) as EnemyHit;
         _loc5_.time_ = param1;
         _loc5_.bulletId_ = param2;
         _loc5_.targetId_ = param3;
         _loc5_.kill_ = param4;
         serverConnection.sendMessage(_loc5_);
      }
      
      override public function otherHit(param1:int, param2:int, param3:int, param4:int) : void
      {
         var _loc5_:OtherHit = this.messages.require(OTHERHIT) as OtherHit;
         _loc5_.time_ = param1;
         _loc5_.bulletId_ = param2;
         _loc5_.objectId_ = param3;
         _loc5_.targetId_ = param4;
         serverConnection.sendMessage(_loc5_);
      }
      
      override public function squareHit(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:SquareHit = this.messages.require(SQUAREHIT) as SquareHit;
         _loc4_.time_ = param1;
         _loc4_.bulletId_ = param2;
         _loc4_.objectId_ = param3;
         serverConnection.sendMessage(_loc4_);
      }
      
      public function aoeAck(param1:int, param2:Number, param3:Number) : void
      {
         var _loc4_:AoeAck = this.messages.require(AOEACK) as AoeAck;
         _loc4_.time_ = param1;
         _loc4_.position_.x_ = param2;
         _loc4_.position_.y_ = param3;
         serverConnection.sendMessage(_loc4_);
      }
      
      override public function groundDamage(param1:int, param2:Number, param3:Number) : void
      {
         var _loc4_:GroundDamage = this.messages.require(GROUNDDAMAGE) as GroundDamage;
         _loc4_.time_ = param1;
         _loc4_.position_.x_ = param2;
         _loc4_.position_.y_ = param3;
         if(!Parameters.data_.GodMode)
         {
            serverConnection.sendMessage(_loc4_);
         }
      }
      
      public function shootAck(param1:int) : void
      {
         var _loc2_:ShootAck = this.messages.require(SHOOTACK) as ShootAck;
         _loc2_.time_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      override public function playerText(param1:String) : void
      {
         var _loc2_:PlayerText = this.messages.require(PLAYERTEXT) as PlayerText;
         _loc2_.text_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      override public function invSwap(param1:Player, param2:GameObject, param3:int, param4:int, param5:GameObject, param6:int, param7:int) : Boolean
      {
         if(!gs_)
         {
            return false;
         }
         var _loc8_:InvSwap = this.messages.require(INVSWAP) as InvSwap;
         _loc8_.time_ = gs_.lastUpdate_;
         _loc8_.position_.x_ = param1.x_;
         _loc8_.position_.y_ = param1.y_;
         _loc8_.slotObject1_.objectId_ = param2.objectId_;
         _loc8_.slotObject1_.slotId_ = param3;
         _loc8_.slotObject1_.objectType_ = param4;
         _loc8_.slotObject2_.objectId_ = param5.objectId_;
         _loc8_.slotObject2_.slotId_ = param6;
         _loc8_.slotObject2_.objectType_ = param7;
         serverConnection.sendMessage(_loc8_);
         var _loc9_:int = param2.equipment_[param3];
         param2.equipment_[param3] = param5.equipment_[param6];
         param5.equipment_[param6] = _loc9_;
         SoundEffectLibrary.play("inventory_move_item");
         return true;
      }
      
      override public function invSwapPotion(param1:Player, param2:GameObject, param3:int, param4:int, param5:GameObject, param6:int, param7:int) : Boolean
      {
         if(!gs_)
         {
            return false;
         }
         var _loc8_:InvSwap = this.messages.require(INVSWAP) as InvSwap;
         _loc8_.time_ = gs_.lastUpdate_;
         _loc8_.position_.x_ = param1.x_;
         _loc8_.position_.y_ = param1.y_;
         _loc8_.slotObject1_.objectId_ = param2.objectId_;
         _loc8_.slotObject1_.slotId_ = param3;
         _loc8_.slotObject1_.objectType_ = param4;
         _loc8_.slotObject2_.objectId_ = param5.objectId_;
         _loc8_.slotObject2_.slotId_ = param6;
         _loc8_.slotObject2_.objectType_ = param7;
         param2.equipment_[param3] = ItemConstants.NO_ITEM;
         if(param4 == PotionInventoryModel.HEALTH_POTION_ID)
         {
            ++param1.healthPotionCount_;
         }
         else if(param4 == PotionInventoryModel.MAGIC_POTION_ID)
         {
            ++param1.magicPotionCount_;
         }
         serverConnection.sendMessage(_loc8_);
         SoundEffectLibrary.play("inventory_move_item");
         return true;
      }
      
      override public function invDrop(param1:GameObject, param2:int, param3:int) : void
      {
         var _loc4_:InvDrop = this.messages.require(INVDROP) as InvDrop;
         _loc4_.slotObject_.objectId_ = param1.objectId_;
         _loc4_.slotObject_.slotId_ = param2;
         _loc4_.slotObject_.objectType_ = param3;
         serverConnection.sendMessage(_loc4_);
         if(param2 != PotionInventoryModel.HEALTH_POTION_SLOT && param2 != PotionInventoryModel.MAGIC_POTION_SLOT)
         {
            param1.equipment_[param2] = ItemConstants.NO_ITEM;
         }
      }
      
      override public function useItem(param1:int, param2:int, param3:int, param4:int, param5:Number, param6:Number, param7:int) : void
      {
         var _loc8_:UseItem = this.messages.require(USEITEM) as UseItem;
         _loc8_.time_ = param1;
         _loc8_.slotObject_.objectId_ = param2;
         _loc8_.slotObject_.slotId_ = param3;
         _loc8_.slotObject_.objectType_ = param4;
         _loc8_.itemUsePos_.x_ = param5;
         _loc8_.itemUsePos_.y_ = param6;
         _loc8_.useType_ = param7;
         serverConnection.sendMessage(_loc8_);
      }
      
      override public function useItem_new(param1:GameObject, param2:int) : Boolean
      {
         var _loc3_:int = param1.equipment_[param2];
         var _loc4_:XML = ObjectLibrary.xmlLibrary_[_loc3_];
         if(_loc4_ && !param1.isPaused() && (_loc4_.hasOwnProperty("Consumable") || _loc4_.hasOwnProperty("InvUse")))
         {
            if(!this.validStatInc(_loc3_,param1))
            {
               this.addTextLine.dispatch(ChatMessage.make("",_loc4_.attribute("id") + " not consumed. Already at Max."));
               return false;
            }
            if(isStatPotion(_loc3_))
            {
               this.addTextLine.dispatch(ChatMessage.make("",_loc4_.attribute("id") + " Consumed ++"));
            }
            this.applyUseItem(param1,param2,_loc3_,_loc4_);
            SoundEffectLibrary.play("use_potion");
            return true;
         }
         SoundEffectLibrary.play("error");
         return false;
      }
      
      private function validStatInc(param1:int, param2:GameObject) : Boolean
      {
         var p:Player = null;
         var itemId:int = param1;
         var itemOwner:GameObject = param2;
         try
         {
            if(itemOwner is Player)
            {
               p = itemOwner as Player;
            }
            else
            {
               p = this.player;
            }
            if((itemId == 2591 || itemId == 5465 || itemId == 9064) && p.attackMax_ == p.attack_ - p.attackBoost_ || (itemId == 2592 || itemId == 5466 || itemId == 9065) && p.defenseMax_ == p.defense_ - p.defenseBoost_ || (itemId == 2593 || itemId == 5467 || itemId == 9066) && p.speedMax_ == p.speed_ - p.speedBoost_ || (itemId == 2612 || itemId == 5468 || itemId == 9067) && p.vitalityMax_ == p.vitality_ - p.vitalityBoost_ || (itemId == 2613 || itemId == 5469 || itemId == 9068) && p.wisdomMax_ == p.wisdom_ - p.wisdomBoost_ || (itemId == 2636 || itemId == 5470 || itemId == 9069) && p.dexterityMax_ == p.dexterity_ - p.dexterityBoost_ || (itemId == 2793 || itemId == 5471 || itemId == 9070) && p.maxHPMax_ == p.maxHP_ - p.maxHPBoost_ || (itemId == 2794 || itemId == 5472 || itemId == 9071) && p.maxMPMax_ == p.maxMP_ - p.maxMPBoost_)
            {
               return false;
            }
         }
         catch(err:Error)
         {
            logger.error("PROBLEM IN STAT INC " + err.getStackTrace());
         }
         return true;
      }
      
      private function applyUseItem(param1:GameObject, param2:int, param3:int, param4:XML) : void
      {
         var _loc5_:UseItem = this.messages.require(USEITEM) as UseItem;
         _loc5_.time_ = getTimer();
         _loc5_.slotObject_.objectId_ = param1.objectId_;
         _loc5_.slotObject_.slotId_ = param2;
         _loc5_.slotObject_.objectType_ = param3;
         _loc5_.itemUsePos_.x_ = 0;
         _loc5_.itemUsePos_.y_ = 0;
         serverConnection.sendMessage(_loc5_);
         if(param4.hasOwnProperty("Consumable"))
         {
            param1.equipment_[param2] = -1;
         }
      }
      
      override public function setCondition(param1:uint, param2:Number) : void
      {
         var _loc3_:SetCondition = this.messages.require(SETCONDITION) as SetCondition;
         _loc3_.conditionEffect_ = param1;
         _loc3_.conditionDuration_ = param2;
         serverConnection.sendMessage(_loc3_);
      }
      
      public function move(param1:int, param2:Player) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Number = -1;
         var _loc6_:Number = -1;
         if(param2 && !param2.isPaused())
         {
            _loc5_ = param2.x_;
            _loc6_ = param2.y_;
         }
         var _loc7_:Move = this.messages.require(MOVE) as Move;
         _loc7_.tickId_ = param1;
         _loc7_.time_ = gs_.lastUpdate_;
         _loc7_.newPosition_.x_ = _loc5_;
         _loc7_.newPosition_.y_ = _loc6_;
         var _loc8_:int = gs_.moveRecords_.lastClearTime_;
         _loc7_.records_.length = 0;
         if(_loc8_ >= 0 && _loc7_.time_ - _loc8_ > 125)
         {
            _loc3_ = Math.min(10,gs_.moveRecords_.records_.length);
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(gs_.moveRecords_.records_[_loc4_].time_ >= _loc7_.time_ - 25)
               {
                  break;
               }
               _loc7_.records_.push(gs_.moveRecords_.records_[_loc4_]);
               _loc4_++;
            }
         }
         gs_.moveRecords_.clear(_loc7_.time_);
         serverConnection.sendMessage(_loc7_);
         param2 && param2.onMove();
      }
      
      override public function teleport(param1:int) : void
      {
         var _loc2_:Teleport = this.messages.require(TELEPORT) as Teleport;
         _loc2_.objectId_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      override public function usePortal(param1:int) : void
      {
         var _loc2_:UsePortal = this.messages.require(USEPORTAL) as UsePortal;
         _loc2_.objectId_ = param1;
         serverConnection.sendMessage(_loc2_);
         this.checkDavyKeyRemoval();
      }
      
      private function checkDavyKeyRemoval() : void
      {
         if(gs_.map && gs_.map.name_ == "Davy Jones\' Locker")
         {
            ShowHideKeyUISignal.instance.dispatch();
         }
      }
      
      override public function buy(param1:int, param2:int) : void
      {
         var _loc4_:Boolean = false;
         if(outstandingBuy_ != null)
         {
            return;
         }
         var _loc3_:SellableObject = gs_.map.goDict_[param1];
         if(_loc3_ == null)
         {
            return;
         }
         if(_loc3_.currency_ == Currency.GOLD)
         {
            _loc4_ = gs_.model.getConverted() || this.player.credits_ > 100 || _loc3_.price_ > this.player.credits_;
         }
         outstandingBuy_ = new OutstandingBuy(_loc3_.soldObjectInternalName(),_loc3_.price_,_loc3_.currency_,_loc4_);
         var _loc5_:Buy = this.messages.require(BUY) as Buy;
         _loc5_.objectId_ = param1;
         _loc5_.quantity_ = param2;
         serverConnection.sendMessage(_loc5_);
      }
      
      public function gotoAck(param1:int) : void
      {
         var _loc2_:GotoAck = this.messages.require(GOTOACK) as GotoAck;
         _loc2_.time_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      override public function editAccountList(param1:int, param2:Boolean, param3:int) : void
      {
         var _loc4_:EditAccountList = this.messages.require(EDITACCOUNTLIST) as EditAccountList;
         _loc4_.accountListId_ = param1;
         _loc4_.add_ = param2;
         _loc4_.objectId_ = param3;
         serverConnection.sendMessage(_loc4_);
      }
      
      override public function chooseName(param1:String) : void
      {
         var _loc2_:ChooseName = this.messages.require(CHOOSENAME) as ChooseName;
         _loc2_.name_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      override public function createGuild(param1:String) : void
      {
         var _loc2_:CreateGuild = this.messages.require(CREATEGUILD) as CreateGuild;
         _loc2_.name_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      override public function guildRemove(param1:String) : void
      {
         var _loc2_:GuildRemove = this.messages.require(GUILDREMOVE) as GuildRemove;
         _loc2_.name_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      override public function guildInvite(param1:String) : void
      {
         var _loc2_:GuildInvite = this.messages.require(GUILDINVITE) as GuildInvite;
         _loc2_.name_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      override public function requestTrade(param1:String) : void
      {
         var _loc2_:RequestTrade = this.messages.require(REQUESTTRADE) as RequestTrade;
         _loc2_.name_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      override public function changeTrade(param1:Vector.<Boolean>) : void
      {
         var _loc2_:ChangeTrade = this.messages.require(CHANGETRADE) as ChangeTrade;
         _loc2_.offer_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      override public function acceptTrade(param1:Vector.<Boolean>, param2:Vector.<Boolean>) : void
      {
         var _loc3_:AcceptTrade = this.messages.require(ACCEPTTRADE) as AcceptTrade;
         _loc3_.myOffer_ = param1;
         _loc3_.yourOffer_ = param2;
         serverConnection.sendMessage(_loc3_);
      }
      
      override public function cancelTrade() : void
      {
         serverConnection.sendMessage(this.messages.require(CANCELTRADE));
      }
      
      override public function checkCredits() : void
      {
         serverConnection.sendMessage(this.messages.require(CHECKCREDITS));
      }
      
      override public function escape() : void
      {
         if(this.playerId_ == -1)
         {
            return;
         }
         if(gs_.map && gs_.map.name_ == "Arena")
         {
            serverConnection.sendMessage(this.messages.require(ACCEPT_ARENA_DEATH));
         }
         else
         {
            serverConnection.sendMessage(this.messages.require(ESCAPE));
            this.checkDavyKeyRemoval();
         }
      }
      
      override public function joinGuild(param1:String) : void
      {
         var _loc2_:JoinGuild = this.messages.require(JOINGUILD) as JoinGuild;
         _loc2_.guildName_ = param1;
         serverConnection.sendMessage(_loc2_);
      }
      
      override public function changeGuildRank(param1:String, param2:int) : void
      {
         var _loc3_:ChangeGuildRank = this.messages.require(CHANGEGUILDRANK) as ChangeGuildRank;
         _loc3_.name_ = param1;
         _loc3_.guildRank_ = param2;
         serverConnection.sendMessage(_loc3_);
      }
      
      private function rsaEncrypt(param1:String) : String
      {
         var _loc2_:RSAKey = PEM.readRSAPublicKey(Parameters.RSA_PUBLIC_KEY);
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeUTFBytes(param1);
         var _loc4_:ByteArray = new ByteArray();
         _loc2_.encrypt(_loc3_,_loc4_,_loc3_.length);
         return Base64.encodeByteArray(_loc4_);
      }
      
      private function onConnected() : void
      {
         var _loc1_:Account = StaticInjectorContext.getInjector().getInstance(Account);
         this.addTextLine.dispatch(ChatMessage.make(Parameters.CLIENT_CHAT_NAME,TextKey.CHAT_CONNECTED));
         this.encryptConnection();
         var _loc2_:Hello = this.messages.require(HELLO) as Hello;
         _loc2_.buildVersion_ = Parameters.CLIENT_VERSION;
         _loc2_.gameId_ = gameId_;
         _loc2_.guid_ = this.rsaEncrypt(_loc1_.getUserId());
         _loc2_.password_ = this.rsaEncrypt(_loc1_.getPassword());
         _loc2_.secret_ = this.rsaEncrypt(_loc1_.getSecret());
         _loc2_.keyTime_ = keyTime_;
         _loc2_.key_.length = 0;
         key_ != null && _loc2_.key_.writeBytes(key_);
         _loc2_.mapJSON_ = mapJSON_ == null ? "" : mapJSON_;
         _loc2_.entrytag_ = _loc1_.getEntryTag();
         _loc2_.gameNet = _loc1_.gameNetwork();
         _loc2_.gameNetUserId = _loc1_.gameNetworkUserId();
         _loc2_.playPlatform = _loc1_.playPlatform();
         _loc2_.platformToken = _loc1_.getPlatformToken();
         serverConnection.sendMessage(_loc2_);
      }
      
      private function onCreateSuccess(param1:CreateSuccess) : void
      {
         this.playerId_ = param1.objectId_;
         charId_ = param1.charId_;
         gs_.initialize();
         createCharacter_ = false;
      }
      
      private function onDamage(param1:Damage) : void
      {
         var _loc2_:int = 0;
         var _loc4_:Projectile = null;
         var _loc3_:AbstractMap = gs_.map;
         if(param1.objectId_ >= 0 && param1.bulletId_ > 0)
         {
            _loc2_ = Projectile.findObjId(param1.objectId_,param1.bulletId_);
            _loc4_ = _loc3_.boDict_[_loc2_] as Projectile;
            if(_loc4_ != null && !_loc4_.projProps_.multiHit_)
            {
               _loc3_.removeObj(_loc2_);
            }
         }
         var _loc5_:GameObject = _loc3_.goDict_[param1.targetId_];
         if(_loc5_ != null)
         {
            _loc5_.damage(-1,param1.damageAmount_,param1.effects_,param1.kill_,_loc4_);
         }
      }
      
      private function onServerPlayerShoot(param1:ServerPlayerShoot) : void
      {
         var _loc2_:* = param1.ownerId_ == this.playerId_;
         var _loc3_:GameObject = gs_.map.goDict_[param1.ownerId_];
         if(_loc3_ == null || _loc3_.dead_)
         {
            if(_loc2_)
            {
               this.shootAck(-1);
            }
            return;
         }
         if(_loc3_.objectId_ != this.playerId_ && Parameters.data_.disableAllyParticles)
         {
            return;
         }
         var _loc4_:Projectile = FreeList.newObject(Projectile) as Projectile;
         var _loc5_:Player = _loc3_ as Player;
         if(_loc5_ != null)
         {
            _loc4_.reset(param1.containerType_,0,param1.ownerId_,param1.bulletId_,param1.angle_,gs_.lastUpdate_,_loc5_.projectileIdSetOverrideNew,_loc5_.projectileIdSetOverrideOld);
         }
         else
         {
            _loc4_.reset(param1.containerType_,0,param1.ownerId_,param1.bulletId_,param1.angle_,gs_.lastUpdate_);
         }
         _loc4_.setDamage(param1.damage_);
         gs_.map.addObj(_loc4_,param1.startingPos_.x_,param1.startingPos_.y_);
         if(_loc2_)
         {
            this.shootAck(gs_.lastUpdate_);
         }
      }
      
      private function onAllyShoot(param1:AllyShoot) : void
      {
         var _loc2_:GameObject = gs_.map.goDict_[param1.ownerId_];
         if(_loc2_ == null || _loc2_.dead_ || Parameters.data_.disableAllyParticles)
         {
            return;
         }
         var _loc3_:Projectile = FreeList.newObject(Projectile) as Projectile;
         var _loc4_:Player = _loc2_ as Player;
         if(_loc4_ != null)
         {
            _loc3_.reset(param1.containerType_,0,param1.ownerId_,param1.bulletId_,param1.angle_,gs_.lastUpdate_,_loc4_.projectileIdSetOverrideNew,_loc4_.projectileIdSetOverrideOld);
         }
         else
         {
            _loc3_.reset(param1.containerType_,0,param1.ownerId_,param1.bulletId_,param1.angle_,gs_.lastUpdate_);
         }
         gs_.map.addObj(_loc3_,_loc2_.x_,_loc2_.y_);
         _loc2_.setAttack(param1.containerType_,param1.angle_);
      }
      
      private function onReskinUnlock(param1:ReskinUnlock) : void
      {
         var _loc2_:CharacterSkin = this.classesModel.getCharacterClass(this.model.player.objectType_).skins.getSkin(param1.skinID);
         _loc2_.setState(CharacterSkinState.OWNED);
      }
      
      private function onEnemyShoot(param1:EnemyShoot) : void
      {
         var _loc2_:Projectile = null;
         var _loc3_:Number = NaN;
         var _loc5_:int = 0;
         var _loc4_:GameObject = gs_.map.goDict_[param1.ownerId_];
         if(_loc4_ == null || _loc4_.dead_)
         {
            this.shootAck(-1);
            return;
         }
         while(_loc5_ < param1.numShots_)
         {
            _loc2_ = FreeList.newObject(Projectile) as Projectile;
            _loc3_ = param1.angle_ + param1.angleInc_ * _loc5_;
            _loc2_.reset(_loc4_.objectType_,param1.bulletType_,param1.ownerId_,(param1.bulletId_ + _loc5_) % 256,_loc3_,gs_.lastUpdate_);
            _loc2_.setDamage(param1.damage_);
            gs_.map.addObj(_loc2_,param1.startingPos_.x_,param1.startingPos_.y_);
            _loc5_++;
         }
         this.shootAck(gs_.lastUpdate_);
         _loc4_.setAttack(_loc4_.objectType_,param1.angle_ + param1.angleInc_ * ((param1.numShots_ - 1) / 2));
      }
      
      private function onTradeRequested(param1:TradeRequested) : void
      {
         if(!Parameters.data_.chatTrade)
         {
            return;
         }
         if(Parameters.data_.tradeWithFriends && !this.friendModel.isMyFriend(param1.name_))
         {
            return;
         }
         if(Parameters.data_.showTradePopup)
         {
            gs_.hudView.interactPanel.setOverride(new TradeRequestPanel(gs_,param1.name_));
         }
         this.addTextLine.dispatch(ChatMessage.make("",param1.name_ + " wants to " + "trade with you.  Type \"/trade " + param1.name_ + "\" to trade."));
      }
      
      private function onTradeStart(param1:TradeStart) : void
      {
         gs_.hudView.startTrade(gs_,param1);
      }
      
      private function onTradeChanged(param1:TradeChanged) : void
      {
         gs_.hudView.tradeChanged(param1);
      }
      
      private function onTradeDone(param1:TradeDone) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         gs_.hudView.tradeDone();
         var _loc4_:* = "";
         try
         {
            _loc3_ = JSON.parse(param1.description_);
            _loc4_ = _loc3_.key;
            _loc2_ = _loc3_.tokens;
         }
         catch(e:Error)
         {
         }
         this.addTextLine.dispatch(ChatMessage.make(Parameters.SERVER_CHAT_NAME,_loc4_,-1,-1,"",false,_loc2_));
      }
      
      private function onTradeAccepted(param1:TradeAccepted) : void
      {
         gs_.hudView.tradeAccepted(param1);
      }
      
      private function addObject(param1:ObjectData) : void
      {
         var _loc2_:AbstractMap = gs_.map;
         var _loc3_:GameObject = ObjectLibrary.getObjectFromType(param1.objectType_);
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:ObjectStatusData = param1.status_;
         _loc3_.setObjectId(_loc4_.objectId_);
         _loc2_.addObj(_loc3_,_loc4_.pos_.x_,_loc4_.pos_.y_);
         if(_loc3_ is Player)
         {
            this.handleNewPlayer(_loc3_ as Player,_loc2_);
         }
         this.processObjectStatus(_loc4_,0,-1);
         if(_loc3_.props_.static_ && _loc3_.props_.occupySquare_ && !_loc3_.props_.noMiniMap_)
         {
            this.updateGameObjectTileSignal.dispatch(new UpdateGameObjectTileVO(_loc3_.x_,_loc3_.y_,_loc3_));
         }
      }
      
      private function handleNewPlayer(param1:Player, param2:AbstractMap) : void
      {
         this.setPlayerSkinTemplate(param1,0);
         if(param1.objectId_ == this.playerId_)
         {
            this.player = param1;
            this.model.player = param1;
            param2.player_ = param1;
            gs_.setFocus(param1);
            this.setGameFocus.dispatch(this.playerId_.toString());
         }
      }
      
      private function onUpdate(param1:Update) : void
      {
         var _loc2_:int = 0;
         var _loc3_:GroundTileData = null;
         var _loc4_:Message = this.messages.require(UPDATEACK);
         serverConnection.sendMessage(_loc4_);
         _loc2_ = 0;
         while(_loc2_ < param1.tiles_.length)
         {
            _loc3_ = param1.tiles_[_loc2_];
            gs_.map.setGroundTile(_loc3_.x_,_loc3_.y_,_loc3_.type_);
            this.updateGroundTileSignal.dispatch(new UpdateGroundTileVO(_loc3_.x_,_loc3_.y_,_loc3_.type_));
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < param1.newObjs_.length)
         {
            this.addObject(param1.newObjs_[_loc2_]);
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < param1.drops_.length)
         {
            gs_.map.removeObj(param1.drops_[_loc2_]);
            _loc2_++;
         }
      }
      
      private function onNotification(param1:Notification) : void
      {
         var _loc2_:LineBuilder = null;
         var _loc3_:CharacterStatusText = null;
         var _loc4_:QueuedStatusText = null;
         var _loc5_:GameObject = gs_.map.goDict_[param1.objectId_];
         if(_loc5_ != null)
         {
            _loc2_ = LineBuilder.fromJSON(param1.message);
            if(_loc2_.key == "server.plus_symbol")
            {
               _loc3_ = new CharacterStatusText(_loc5_,param1.color_,1000);
               _loc3_.setStringBuilder(_loc2_);
               gs_.map.mapOverlay_.addStatusText(_loc3_);
            }
            else
            {
               _loc4_ = new QueuedStatusText(_loc5_,_loc2_,param1.color_,2000);
               gs_.map.mapOverlay_.addQueuedText(_loc4_);
               if(_loc5_ == this.player && _loc2_.key == "server.quest_complete")
               {
                  gs_.map.quest_.completed();
               }
            }
         }
      }
      
      private function onGlobalNotification(param1:GlobalNotification) : void
      {
         switch(param1.text)
         {
            case "yellow":
               ShowKeySignal.instance.dispatch(Key.YELLOW);
               return;
            case "red":
               ShowKeySignal.instance.dispatch(Key.RED);
               return;
            case "green":
               ShowKeySignal.instance.dispatch(Key.GREEN);
               return;
            case "purple":
               ShowKeySignal.instance.dispatch(Key.PURPLE);
               return;
            case "showKeyUI":
               ShowHideKeyUISignal.instance.dispatch();
               return;
            case "giftChestOccupied":
               this.giftChestUpdateSignal.dispatch(GiftStatusUpdateSignal.HAS_GIFT);
               return;
            case "giftChestEmpty":
               this.giftChestUpdateSignal.dispatch(GiftStatusUpdateSignal.HAS_NO_GIFT);
               return;
            case "beginnersPackage":
               return;
            default:
               return;
         }
      }
      
      private function onNewTick(param1:NewTick) : void
      {
         var _loc2_:ObjectStatusData = null;
         if(jitterWatcher_ != null)
         {
            jitterWatcher_.record();
         }
         this.move(param1.tickId_,this.player);
         for each(_loc2_ in param1.statuses_)
         {
            this.processObjectStatus(_loc2_,param1.tickTime_,param1.tickId_);
         }
         lastTickId_ = param1.tickId_;
      }
      
      private function canShowEffect(param1:GameObject) : Boolean
      {
         if(param1 != null)
         {
            return true;
         }
         var _loc2_:* = param1.objectId_ == this.playerId_;
         if(!_loc2_ && param1.props_.isPlayer_ && Parameters.data_.disableAllyParticles)
         {
            return false;
         }
         return true;
      }
      
      private function onShowEffect(param1:ShowEffect) : void
      {
         var _loc2_:GameObject = null;
         var _loc3_:ParticleEffect = null;
         var _loc4_:Point = null;
         var _loc5_:uint = 0;
         var _loc6_:AbstractMap = gs_.map;
         switch(param1.effectType_)
         {
            case ShowEffect.HEAL_EFFECT_TYPE:
               _loc2_ = _loc6_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null || !this.canShowEffect(_loc2_))
               {
                  break;
               }
               _loc6_.addObj(new HealEffect(_loc2_,param1.color_),_loc2_.x_,_loc2_.y_);
               return;
               break;
            case ShowEffect.TELEPORT_EFFECT_TYPE:
               _loc6_.addObj(new TeleportEffect(),param1.pos1_.x_,param1.pos1_.y_);
               return;
            case ShowEffect.STREAM_EFFECT_TYPE:
               _loc3_ = new StreamEffect(param1.pos1_,param1.pos2_,param1.color_);
               _loc6_.addObj(_loc3_,param1.pos1_.x_,param1.pos1_.y_);
               return;
            case ShowEffect.THROW_EFFECT_TYPE:
               _loc2_ = _loc6_.goDict_[param1.targetObjectId_];
               _loc4_ = _loc2_ != null ? new Point(_loc2_.x_,_loc2_.y_) : param1.pos2_.toPoint();
               if(_loc2_ != null && !this.canShowEffect(_loc2_))
               {
                  break;
               }
               _loc3_ = new ThrowEffect(_loc4_,param1.pos1_.toPoint(),param1.color_);
               _loc6_.addObj(_loc3_,_loc4_.x,_loc4_.y);
               return;
               break;
            case ShowEffect.NOVA_EFFECT_TYPE:
               _loc2_ = _loc6_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null || !this.canShowEffect(_loc2_))
               {
                  break;
               }
               _loc3_ = new NovaEffect(_loc2_,param1.pos1_.x_,param1.color_);
               _loc6_.addObj(_loc3_,_loc2_.x_,_loc2_.y_);
               return;
               break;
            case ShowEffect.POISON_EFFECT_TYPE:
               _loc2_ = _loc6_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null || !this.canShowEffect(_loc2_))
               {
                  break;
               }
               _loc3_ = new PoisonEffect(_loc2_,param1.color_);
               _loc6_.addObj(_loc3_,_loc2_.x_,_loc2_.y_);
               return;
               break;
            case ShowEffect.LINE_EFFECT_TYPE:
               _loc2_ = _loc6_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null || !this.canShowEffect(_loc2_))
               {
                  break;
               }
               _loc3_ = new LineEffect(_loc2_,param1.pos1_,param1.color_);
               _loc6_.addObj(_loc3_,param1.pos1_.x_,param1.pos1_.y_);
               return;
               break;
            case ShowEffect.BURST_EFFECT_TYPE:
               _loc2_ = _loc6_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null || !this.canShowEffect(_loc2_))
               {
                  break;
               }
               _loc3_ = new BurstEffect(_loc2_,param1.pos1_,param1.pos2_,param1.color_);
               _loc6_.addObj(_loc3_,param1.pos1_.x_,param1.pos1_.y_);
               return;
               break;
            case ShowEffect.FLOW_EFFECT_TYPE:
               _loc2_ = _loc6_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null || !this.canShowEffect(_loc2_))
               {
                  break;
               }
               _loc3_ = new FlowEffect(param1.pos1_,_loc2_,param1.color_);
               _loc6_.addObj(_loc3_,param1.pos1_.x_,param1.pos1_.y_);
               return;
               break;
            case ShowEffect.RING_EFFECT_TYPE:
               _loc2_ = _loc6_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null || !this.canShowEffect(_loc2_))
               {
                  break;
               }
               _loc3_ = new RingEffect(_loc2_,param1.pos1_.x_,param1.color_);
               _loc6_.addObj(_loc3_,_loc2_.x_,_loc2_.y_);
               return;
               break;
            case ShowEffect.LIGHTNING_EFFECT_TYPE:
               _loc2_ = _loc6_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null || !this.canShowEffect(_loc2_))
               {
                  break;
               }
               _loc3_ = new LightningEffect(_loc2_,param1.pos1_,param1.color_,param1.pos2_.x_);
               _loc6_.addObj(_loc3_,_loc2_.x_,_loc2_.y_);
               return;
               break;
            case ShowEffect.COLLAPSE_EFFECT_TYPE:
               _loc2_ = _loc6_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null || this.canShowEffect(_loc2_))
               {
                  break;
               }
               _loc3_ = new CollapseEffect(_loc2_,param1.pos1_,param1.pos2_,param1.color_);
               _loc6_.addObj(_loc3_,param1.pos1_.x_,param1.pos1_.y_);
               return;
               break;
            case ShowEffect.CONEBLAST_EFFECT_TYPE:
               _loc2_ = _loc6_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null || !this.canShowEffect(_loc2_))
               {
                  break;
               }
               _loc3_ = new ConeBlastEffect(_loc2_,param1.pos1_,param1.pos2_.x_,param1.color_);
               _loc6_.addObj(_loc3_,_loc2_.x_,_loc2_.y_);
               return;
               break;
            case ShowEffect.JITTER_EFFECT_TYPE:
               gs_.camera_.startJitter();
               return;
            case ShowEffect.FLASH_EFFECT_TYPE:
               _loc2_ = _loc6_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null || !this.canShowEffect(_loc2_))
               {
                  break;
               }
               _loc2_.flash_ = new FlashDescription(getTimer(),param1.color_,param1.pos1_.x_,param1.pos1_.y_);
               return;
               break;
            case ShowEffect.THROW_PROJECTILE_EFFECT_TYPE:
               _loc4_ = param1.pos1_.toPoint();
               if(_loc2_ != null && !this.canShowEffect(_loc2_))
               {
                  break;
               }
               _loc3_ = new ThrowProjectileEffect(param1.color_,param1.pos2_.toPoint(),param1.pos1_.toPoint());
               _loc6_.addObj(_loc3_,_loc4_.x,_loc4_.y);
               return;
               break;
            case ShowEffect.SHOCKER_EFFECT_TYPE:
               _loc2_ = _loc6_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null || !this.canShowEffect(_loc2_))
               {
                  break;
               }
               if(_loc2_ && _loc2_.shockEffect)
               {
                  _loc2_.shockEffect.destroy();
               }
               _loc3_ = new ShockerEffect(_loc2_);
               _loc2_.shockEffect = ShockerEffect(_loc3_);
               gs_.map.addObj(_loc3_,_loc2_.x_,_loc2_.y_);
               return;
               break;
            case ShowEffect.SHOCKEE_EFFECT_TYPE:
               _loc2_ = _loc6_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null || !this.canShowEffect(_loc2_))
               {
                  break;
               }
               _loc3_ = new ShockeeEffect(_loc2_);
               gs_.map.addObj(_loc3_,_loc2_.x_,_loc2_.y_);
               return;
               break;
            case ShowEffect.RISING_FURY_EFFECT_TYPE:
               _loc2_ = _loc6_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null || !this.canShowEffect(_loc2_))
               {
                  break;
               }
               _loc5_ = param1.pos1_.x_ * 1000;
               _loc3_ = new RisingFuryEffect(_loc2_,_loc5_);
               gs_.map.addObj(_loc3_,_loc2_.x_,_loc2_.y_);
               return;
         }
      }
      
      private function onGoto(param1:Goto) : void
      {
         this.gotoAck(gs_.lastUpdate_);
         var _loc2_:GameObject = gs_.map.goDict_[param1.objectId_];
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.onGoto(param1.pos_.x_,param1.pos_.y_,gs_.lastUpdate_);
      }
      
      private function updateGameObject(param1:GameObject, param2:Vector.<StatData>, param3:Boolean) : void
      {
         var _loc4_:StatData = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Player = param1 as Player;
         var _loc8_:Merchant = param1 as Merchant;
         var _loc9_:Pet = param1 as Pet;
         if(_loc9_)
         {
            this.petUpdater.updatePet(_loc9_,param2);
            if(gs_.map.isPetYard)
            {
               this.petUpdater.updatePetVOs(_loc9_,param2);
            }
            return;
         }
         for each(_loc4_ in param2)
         {
            _loc5_ = _loc4_.statValue_;
            switch(_loc4_.statType_)
            {
               case StatData.MAX_HP_STAT:
                  param1.maxHP_ = _loc5_;
                  break;
               case StatData.HP_STAT:
                  param1.hp_ = _loc5_;
                  break;
               case StatData.SIZE_STAT:
                  param1.size_ = _loc5_;
                  break;
               case StatData.MAX_MP_STAT:
                  _loc7_.maxMP_ = _loc5_;
                  break;
               case StatData.MP_STAT:
                  _loc7_.mp_ = _loc5_;
                  break;
               case StatData.NEXT_LEVEL_EXP_STAT:
                  _loc7_.nextLevelExp_ = _loc5_;
                  break;
               case StatData.EXP_STAT:
                  _loc7_.exp_ = _loc5_;
                  break;
               case StatData.LEVEL_STAT:
                  param1.level_ = _loc5_;
                  break;
               case StatData.ATTACK_STAT:
                  _loc7_.attack_ = _loc5_;
                  break;
               case StatData.DEFENSE_STAT:
                  param1.defense_ = _loc5_;
                  break;
               case StatData.SPEED_STAT:
                  _loc7_.speed_ = _loc5_;
                  break;
               case StatData.DEXTERITY_STAT:
                  _loc7_.dexterity_ = _loc5_;
                  break;
               case StatData.VITALITY_STAT:
                  _loc7_.vitality_ = _loc5_;
                  break;
               case StatData.WISDOM_STAT:
                  _loc7_.wisdom_ = _loc5_;
                  break;
               case StatData.CONDITION_STAT:
                  param1.condition_[ConditionEffect.CE_FIRST_BATCH] = _loc5_;
                  break;
               case StatData.INVENTORY_0_STAT:
               case StatData.INVENTORY_1_STAT:
               case StatData.INVENTORY_2_STAT:
               case StatData.INVENTORY_3_STAT:
               case StatData.INVENTORY_4_STAT:
               case StatData.INVENTORY_5_STAT:
               case StatData.INVENTORY_6_STAT:
               case StatData.INVENTORY_7_STAT:
               case StatData.INVENTORY_8_STAT:
               case StatData.INVENTORY_9_STAT:
               case StatData.INVENTORY_10_STAT:
               case StatData.INVENTORY_11_STAT:
                  param1.equipment_[_loc4_.statType_ - StatData.INVENTORY_0_STAT] = _loc5_;
                  break;
               case StatData.NUM_STARS_STAT:
                  _loc7_.numStars_ = _loc5_;
                  break;
               case StatData.NAME_STAT:
                  if(param1.name_ != _loc4_.strStatValue_)
                  {
                     param1.name_ = _loc4_.strStatValue_;
                     param1.nameBitmapData_ = null;
                  }
                  break;
               case StatData.TEX1_STAT:
                  param1.setTex1(_loc5_);
                  break;
               case StatData.TEX2_STAT:
                  param1.setTex2(_loc5_);
                  break;
               case StatData.MERCHANDISE_TYPE_STAT:
                  _loc8_.setMerchandiseType(_loc5_);
                  break;
               case StatData.CREDITS_STAT:
                  _loc7_.setCredits(_loc5_);
                  break;
               case StatData.MERCHANDISE_PRICE_STAT:
                  (param1 as SellableObject).setPrice(_loc5_);
                  break;
               case StatData.ACTIVE_STAT:
                  (param1 as Portal).active_ = _loc5_ != 0;
                  break;
               case StatData.ACCOUNT_ID_STAT:
                  _loc7_.accountId_ = _loc4_.strStatValue_;
                  break;
               case StatData.FAME_STAT:
                  _loc7_.fame_ = _loc5_;
                  break;
               case StatData.FORTUNE_TOKEN_STAT:
                  _loc7_.setTokens(_loc5_);
                  break;
               case StatData.MERCHANDISE_CURRENCY_STAT:
                  (param1 as SellableObject).setCurrency(_loc5_);
                  break;
               case StatData.CONNECT_STAT:
                  param1.connectType_ = _loc5_;
                  break;
               case StatData.MERCHANDISE_COUNT_STAT:
                  _loc8_.count_ = _loc5_;
                  _loc8_.untilNextMessage_ = 0;
                  break;
               case StatData.MERCHANDISE_MINS_LEFT_STAT:
                  _loc8_.minsLeft_ = _loc5_;
                  _loc8_.untilNextMessage_ = 0;
                  break;
               case StatData.MERCHANDISE_DISCOUNT_STAT:
                  _loc8_.discount_ = _loc5_;
                  _loc8_.untilNextMessage_ = 0;
                  break;
               case StatData.MERCHANDISE_RANK_REQ_STAT:
                  (param1 as SellableObject).setRankReq(_loc5_);
                  break;
               case StatData.MAX_HP_BOOST_STAT:
                  _loc7_.maxHPBoost_ = _loc5_;
                  break;
               case StatData.MAX_MP_BOOST_STAT:
                  _loc7_.maxMPBoost_ = _loc5_;
                  break;
               case StatData.ATTACK_BOOST_STAT:
                  _loc7_.attackBoost_ = _loc5_;
                  break;
               case StatData.DEFENSE_BOOST_STAT:
                  _loc7_.defenseBoost_ = _loc5_;
                  break;
               case StatData.SPEED_BOOST_STAT:
                  _loc7_.speedBoost_ = _loc5_;
                  break;
               case StatData.VITALITY_BOOST_STAT:
                  _loc7_.vitalityBoost_ = _loc5_;
                  break;
               case StatData.WISDOM_BOOST_STAT:
                  _loc7_.wisdomBoost_ = _loc5_;
                  break;
               case StatData.DEXTERITY_BOOST_STAT:
                  _loc7_.dexterityBoost_ = _loc5_;
                  break;
               case StatData.OWNER_ACCOUNT_ID_STAT:
                  (param1 as Container).setOwnerId(_loc4_.strStatValue_);
                  break;
               case StatData.RANK_REQUIRED_STAT:
                  (param1 as NameChanger).setRankRequired(_loc5_);
                  break;
               case StatData.NAME_CHOSEN_STAT:
                  _loc7_.nameChosen_ = _loc5_ != 0;
                  param1.nameBitmapData_ = null;
                  break;
               case StatData.CURR_FAME_STAT:
                  _loc7_.currFame_ = _loc5_;
                  break;
               case StatData.NEXT_CLASS_QUEST_FAME_STAT:
                  _loc7_.nextClassQuestFame_ = _loc5_;
                  break;
               case StatData.LEGENDARY_RANK_STAT:
                  _loc7_.legendaryRank_ = _loc5_;
                  break;
               case StatData.SINK_LEVEL_STAT:
                  if(!param3)
                  {
                     _loc7_.sinkLevel_ = _loc5_;
                  }
                  break;
               case StatData.ALT_TEXTURE_STAT:
                  param1.setAltTexture(_loc5_);
                  break;
               case StatData.GUILD_NAME_STAT:
                  _loc7_.setGuildName(_loc4_.strStatValue_);
                  break;
               case StatData.GUILD_RANK_STAT:
                  _loc7_.guildRank_ = _loc5_;
                  break;
               case StatData.BREATH_STAT:
                  _loc7_.breath_ = _loc5_;
                  break;
               case StatData.XP_BOOSTED_STAT:
                  _loc7_.xpBoost_ = _loc5_;
                  break;
               case StatData.XP_TIMER_STAT:
                  _loc7_.xpTimer = _loc5_ * TO_MILLISECONDS;
                  break;
               case StatData.LD_TIMER_STAT:
                  _loc7_.dropBoost = _loc5_ * TO_MILLISECONDS;
                  break;
               case StatData.LT_TIMER_STAT:
                  _loc7_.tierBoost = _loc5_ * TO_MILLISECONDS;
                  break;
               case StatData.HEALTH_POTION_STACK_STAT:
                  _loc7_.healthPotionCount_ = _loc5_;
                  break;
               case StatData.MAGIC_POTION_STACK_STAT:
                  _loc7_.magicPotionCount_ = _loc5_;
                  break;
               case StatData.TEXTURE_STAT:
                  _loc7_.skinId != _loc5_ && this.setPlayerSkinTemplate(_loc7_,_loc5_);
                  break;
               case StatData.HASBACKPACK_STAT:
                  (param1 as Player).hasBackpack_ = Boolean(_loc5_);
                  if(param3)
                  {
                     this.updateBackpackTab.dispatch(Boolean(_loc5_));
                  }
                  break;
               case StatData.BACKPACK_0_STAT:
               case StatData.BACKPACK_1_STAT:
               case StatData.BACKPACK_2_STAT:
               case StatData.BACKPACK_3_STAT:
               case StatData.BACKPACK_4_STAT:
               case StatData.BACKPACK_5_STAT:
               case StatData.BACKPACK_6_STAT:
               case StatData.BACKPACK_7_STAT:
                  _loc6_ = _loc4_.statType_ - StatData.BACKPACK_0_STAT + GeneralConstants.NUM_EQUIPMENT_SLOTS + GeneralConstants.NUM_INVENTORY_SLOTS;
                  (param1 as Player).equipment_[_loc6_] = _loc5_;
                  break;
               case StatData.NEW_CON_STAT:
                  param1.condition_[ConditionEffect.CE_SECOND_BATCH] = _loc5_;
                  break;
            }
         }
      }
      
      private function setPlayerSkinTemplate(param1:Player, param2:int) : void
      {
         var _loc3_:Reskin = this.messages.require(RESKIN) as Reskin;
         _loc3_.skinID = param2;
         _loc3_.player = param1;
         _loc3_.consume();
      }
      
      private function processObjectStatus(param1:ObjectStatusData, param2:int, param3:int) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:CharacterClass = null;
         var _loc8_:XML = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:int = 0;
         var _loc12_:ObjectProperties = null;
         var _loc13_:ProjectileProperties = null;
         var _loc14_:Array = null;
         var _loc15_:AbstractMap = gs_.map;
         var _loc16_:GameObject = _loc15_.goDict_[param1.objectId_];
         if(_loc16_ == null)
         {
            return;
         }
         var _loc17_:* = param1.objectId_ == this.playerId_;
         if(param2 != 0 && !_loc17_)
         {
            _loc16_.onTickPos(param1.pos_.x_,param1.pos_.y_,param2,param3);
         }
         var _loc18_:Player = _loc16_ as Player;
         if(_loc18_ != null)
         {
            _loc4_ = _loc18_.level_;
            _loc5_ = _loc18_.exp_;
            _loc6_ = _loc18_.skinId;
         }
         this.updateGameObject(_loc16_,param1.stats_,_loc17_);
         if(_loc18_)
         {
            if(_loc17_)
            {
               _loc7_ = this.classesModel.getCharacterClass(_loc18_.objectType_);
               if(_loc7_.getMaxLevelAchieved() < _loc18_.level_)
               {
                  _loc7_.setMaxLevelAchieved(_loc18_.level_);
               }
            }
            if(_loc18_.skinId != _loc6_)
            {
               if(ObjectLibrary.skinSetXMLDataLibrary_[_loc18_.skinId] != null)
               {
                  _loc8_ = ObjectLibrary.skinSetXMLDataLibrary_[_loc18_.skinId] as XML;
                  _loc9_ = _loc8_.attribute("color");
                  _loc10_ = _loc8_.attribute("bulletType");
                  if(_loc4_ != -1 && _loc9_.length > 0)
                  {
                     _loc18_.levelUpParticleEffect(uint(_loc9_));
                  }
                  if(_loc10_.length > 0)
                  {
                     _loc18_.projectileIdSetOverrideNew = _loc10_;
                     _loc11_ = _loc18_.equipment_[0];
                     _loc12_ = ObjectLibrary.propsLibrary_[_loc11_];
                     _loc13_ = _loc12_.projectiles_[0];
                     _loc18_.projectileIdSetOverrideOld = _loc13_.objectId_;
                  }
               }
               else if(ObjectLibrary.skinSetXMLDataLibrary_[_loc18_.skinId] == null)
               {
                  _loc18_.projectileIdSetOverrideNew = "";
                  _loc18_.projectileIdSetOverrideOld = "";
               }
            }
            if(_loc4_ != -1 && _loc18_.level_ > _loc4_)
            {
               if(_loc17_)
               {
                  _loc14_ = gs_.model.getNewUnlocks(_loc18_.objectType_,_loc18_.level_);
                  _loc18_.handleLevelUp(_loc14_.length != 0);
               }
               else
               {
                  _loc18_.levelUpEffect(TextKey.PLAYER_LEVELUP);
               }
            }
            else if(_loc4_ != -1 && _loc18_.exp_ > _loc5_)
            {
               _loc18_.handleExpUp(_loc18_.exp_ - _loc5_);
            }
            this.friendModel.updateFriendVO(_loc18_.getName(),_loc18_);
         }
      }
      
      private function onInvResult(param1:InvResult) : void
      {
         if(param1.result_ != 0)
         {
            this.handleInvFailure();
         }
      }
      
      private function handleInvFailure() : void
      {
         SoundEffectLibrary.play("error");
         gs_.hudView.interactPanel.redraw();
      }
      
      private function onReconnect(param1:Reconnect) : void
      {
         var _loc2_:Server = new Server().setName(param1.name_).setAddress(param1.host_ != "" ? param1.host_ : server_.address).setPort(param1.host_ != "" ? int(param1.port_) : int(server_.port));
         var _loc3_:int = param1.gameId_;
         var _loc4_:Boolean = createCharacter_;
         var _loc5_:int = charId_;
         var _loc6_:int = param1.keyTime_;
         var _loc7_:ByteArray = param1.key_;
         isFromArena_ = param1.isFromArena_;
         var _loc8_:ReconnectEvent = new ReconnectEvent(_loc2_,_loc3_,_loc4_,_loc5_,_loc6_,_loc7_,isFromArena_);
         gs_.dispatchEvent(_loc8_);
      }
      
      private function onPing(param1:Ping) : void
      {
         var _loc2_:Pong = this.messages.require(PONG) as Pong;
         _loc2_.serial_ = param1.serial_;
         _loc2_.time_ = getTimer();
         serverConnection.sendMessage(_loc2_);
      }
      
      private function parseXML(param1:String) : void
      {
         var _loc2_:XML = XML(param1);
         GroundLibrary.parseFromXML(_loc2_);
         ObjectLibrary.parseFromXML(_loc2_);
         ObjectLibrary.parseFromXML(_loc2_);
      }
      
      private function onMapInfo(param1:MapInfo) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         for each(_loc2_ in param1.clientXML_)
         {
            this.parseXML(_loc2_);
         }
         for each(_loc3_ in param1.extraXML_)
         {
            this.parseXML(_loc3_);
         }
         changeMapSignal.dispatch();
         this.closeDialogs.dispatch();
         gs_.applyMapInfo(param1);
         this.rand_ = new Random(param1.fp_);
         if(createCharacter_)
         {
            this.create();
         }
         else
         {
            this.load();
         }
      }
      
      private function onPic(param1:Pic) : void
      {
         gs_.addChild(new PicView(param1.bitmapData_));
      }
      
      private function onDeath(param1:Death) : void
      {
         this.death = param1;
         var _loc2_:BitmapData = new BitmapDataSpy(gs_.stage.stageWidth,gs_.stage.stageHeight);
         _loc2_.draw(gs_);
         param1.background = _loc2_;
         if(!gs_.isEditor)
         {
            this.handleDeath.dispatch(param1);
         }
         this.checkDavyKeyRemoval();
      }
      
      private function onBuyResult(param1:BuyResult) : void
      {
         outstandingBuy_ = null;
         this.handleBuyResultType(param1);
      }
      
      private function handleBuyResultType(param1:BuyResult) : void
      {
         var _loc2_:ChatMessage = null;
         switch(param1.result_)
         {
            case BuyResult.UNKNOWN_ERROR_BRID:
               _loc2_ = ChatMessage.make(Parameters.SERVER_CHAT_NAME,param1.resultString_);
               this.addTextLine.dispatch(_loc2_);
               return;
            case BuyResult.NOT_ENOUGH_GOLD_BRID:
               this.openDialog.dispatch(new NotEnoughGoldDialog());
               return;
            case BuyResult.NOT_ENOUGH_FAME_BRID:
               this.openDialog.dispatch(new NotEnoughFameDialog());
               return;
            default:
               this.handleDefaultResult(param1);
               return;
         }
      }
      
      private function handleDefaultResult(param1:BuyResult) : void
      {
         var _loc2_:LineBuilder = LineBuilder.fromJSON(param1.resultString_);
         var _loc3_:Boolean = param1.result_ == BuyResult.SUCCESS_BRID || param1.result_ == BuyResult.PET_FEED_SUCCESS_BRID;
         var _loc4_:ChatMessage = ChatMessage.make(!!_loc3_ ? Parameters.SERVER_CHAT_NAME : Parameters.ERROR_CHAT_NAME,_loc2_.key);
         _loc4_.tokens = _loc2_.tokens;
         this.addTextLine.dispatch(_loc4_);
      }
      
      private function onAccountList(param1:AccountList) : void
      {
         if(param1.accountListId_ == 0)
         {
            if(param1.lockAction_ != -1)
            {
               if(param1.lockAction_ == 1)
               {
                  gs_.map.party_.setStars(param1);
               }
               else
               {
                  gs_.map.party_.removeStars(param1);
               }
            }
            else
            {
               gs_.map.party_.setStars(param1);
            }
         }
         else if(param1.accountListId_ == 1)
         {
            gs_.map.party_.setIgnores(param1);
         }
      }
      
      private function onQuestObjId(param1:QuestObjId) : void
      {
         gs_.map.quest_.setObject(param1.objectId_);
      }
      
      private function onAoe(param1:Aoe) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Vector.<uint> = null;
         if(this.player == null)
         {
            this.aoeAck(gs_.lastUpdate_,0,0);
            return;
         }
         var _loc4_:AOEEffect = new AOEEffect(param1.pos_.toPoint(),param1.radius_,16711680);
         gs_.map.addObj(_loc4_,param1.pos_.x_,param1.pos_.y_);
         if(this.player.isInvincible() || this.player.isPaused())
         {
            this.aoeAck(gs_.lastUpdate_,this.player.x_,this.player.y_);
            return;
         }
         var _loc5_:* = this.player.distTo(param1.pos_) < param1.radius_;
         if(_loc5_)
         {
            _loc2_ = GameObject.damageWithDefense(param1.damage_,this.player.defense_,false,this.player.condition_);
            _loc3_ = null;
            if(param1.effect_ != 0)
            {
               _loc3_ = new Vector.<uint>();
               _loc3_.push(param1.effect_);
            }
            this.player.damage(param1.origType_,_loc2_,_loc3_,false,null);
         }
         this.aoeAck(gs_.lastUpdate_,this.player.x_,this.player.y_);
      }
      
      private function onNameResult(param1:NameResult) : void
      {
         gs_.dispatchEvent(new NameResultEvent(param1));
      }
      
      private function onGuildResult(param1:GuildResult) : void
      {
         var _loc2_:LineBuilder = null;
         if(param1.lineBuilderJSON == "")
         {
            gs_.dispatchEvent(new GuildResultEvent(param1.success_,"",{}));
         }
         else
         {
            _loc2_ = LineBuilder.fromJSON(param1.lineBuilderJSON);
            this.addTextLine.dispatch(ChatMessage.make(Parameters.ERROR_CHAT_NAME,_loc2_.key,-1,-1,"",false,_loc2_.tokens));
            gs_.dispatchEvent(new GuildResultEvent(param1.success_,_loc2_.key,_loc2_.tokens));
         }
      }
      
      private function onClientStat(param1:ClientStat) : void
      {
         var _loc2_:Account = StaticInjectorContext.getInjector().getInstance(Account);
         _loc2_.reportIntStat(param1.name_,param1.value_);
      }
      
      private function onFile(param1:File) : void
      {
         new FileReference().save(param1.file_,param1.filename_);
      }
      
      private function onInvitedToGuild(param1:InvitedToGuild) : void
      {
         if(Parameters.data_.showGuildInvitePopup)
         {
            gs_.hudView.interactPanel.setOverride(new GuildInvitePanel(gs_,param1.name_,param1.guildName_));
         }
         this.addTextLine.dispatch(ChatMessage.make("","You have been invited by " + param1.name_ + " to join the guild " + param1.guildName_ + ".\n  If you wish to join type \"/join " + param1.guildName_ + "\""));
      }
      
      private function onPlaySound(param1:PlaySound) : void
      {
         var _loc2_:GameObject = gs_.map.goDict_[param1.ownerId_];
         _loc2_ && _loc2_.playSound(param1.soundId_);
      }
      
      private function onImminentArenaWave(param1:ImminentArenaWave) : void
      {
         this.imminentWave.dispatch(param1.currentRuntime);
      }
      
      private function onArenaDeath(param1:ArenaDeath) : void
      {
         this.currentArenaRun.costOfContinue = param1.cost;
         this.openDialog.dispatch(new ContinueOrQuitDialog(param1.cost,false));
         this.arenaDeath.dispatch();
      }
      
      private function onVerifyEmail(param1:VerifyEmail) : void
      {
         TitleView.queueEmailConfirmation = true;
         if(gs_ != null)
         {
            gs_.closed.dispatch();
         }
         var _loc2_:HideMapLoadingSignal = StaticInjectorContext.getInjector().getInstance(HideMapLoadingSignal);
         if(_loc2_ != null)
         {
            _loc2_.dispatch();
         }
      }
      
      private function onPasswordPrompt(param1:PasswordPrompt) : void
      {
         if(param1.cleanPasswordStatus == 3)
         {
            TitleView.queuePasswordPromptFull = true;
         }
         else if(param1.cleanPasswordStatus == 2)
         {
            TitleView.queuePasswordPrompt = true;
         }
         else if(param1.cleanPasswordStatus == 4)
         {
            TitleView.queueRegistrationPrompt = true;
         }
         if(gs_ != null)
         {
            gs_.closed.dispatch();
         }
         var _loc2_:HideMapLoadingSignal = StaticInjectorContext.getInjector().getInstance(HideMapLoadingSignal);
         if(_loc2_ != null)
         {
            _loc2_.dispatch();
         }
      }
      
      override public function questFetch() : void
      {
         serverConnection.sendMessage(this.messages.require(QUEST_FETCH_ASK));
      }
      
      private function onQuestFetchResponse(param1:QuestFetchResponse) : void
      {
         this.questFetchComplete.dispatch(param1);
      }
      
      private function onQuestRedeemResponse(param1:QuestRedeemResponse) : void
      {
         this.questRedeemComplete.dispatch(param1);
      }
      
      override public function questRedeem(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:QuestRedeem = this.messages.require(QUEST_REDEEM) as QuestRedeem;
         _loc4_.slotObject.objectId_ = param1;
         _loc4_.slotObject.slotId_ = param2;
         _loc4_.slotObject.objectType_ = param3;
         serverConnection.sendMessage(_loc4_);
      }
      
      private function onClosed() : void
      {
         var _loc1_:HideMapLoadingSignal = null;
         if(this.playerId_ != -1)
         {
            gs_.closed.dispatch();
         }
         else if(this.retryConnection_)
         {
            if(this.delayBeforeReconnect < 10)
            {
               if(this.delayBeforeReconnect == 6)
               {
                  _loc1_ = StaticInjectorContext.getInjector().getInstance(HideMapLoadingSignal);
                  _loc1_.dispatch();
               }
               this.retry(this.delayBeforeReconnect++);
               this.addTextLine.dispatch(ChatMessage.make(Parameters.ERROR_CHAT_NAME,"Connection failed!  Retrying..."));
            }
            else
            {
               gs_.closed.dispatch();
            }
         }
      }
      
      private function retry(param1:int) : void
      {
         this.retryTimer_ = new Timer(param1 * 1000,1);
         this.retryTimer_.addEventListener(TimerEvent.TIMER_COMPLETE,this.onRetryTimer);
         this.retryTimer_.start();
      }
      
      private function onRetryTimer(param1:TimerEvent) : void
      {
         serverConnection.connect(server_.address,server_.port);
      }
      
      private function onError(param1:String) : void
      {
         this.addTextLine.dispatch(ChatMessage.make(Parameters.ERROR_CHAT_NAME,param1));
      }
      
      private function onFailure(param1:Failure) : void
      {
         switch(param1.errorId_)
         {
            case Failure.INCORRECT_VERSION:
               this.handleIncorrectVersionFailure(param1);
               return;
            case Failure.BAD_KEY:
               this.handleBadKeyFailure(param1);
               return;
            case Failure.INVALID_TELEPORT_TARGET:
               this.handleInvalidTeleportTarget(param1);
               return;
            case Failure.EMAIL_VERIFICATION_NEEDED:
               this.handleEmailVerificationNeeded(param1);
               return;
            default:
               this.handleDefaultFailure(param1);
               return;
         }
      }
      
      private function handleEmailVerificationNeeded(param1:Failure) : void
      {
         this.retryConnection_ = false;
         gs_.closed.dispatch();
      }
      
      private function handleInvalidTeleportTarget(param1:Failure) : void
      {
         var _loc2_:String = LineBuilder.getLocalizedStringFromJSON(param1.errorDescription_);
         if(_loc2_ == "")
         {
            _loc2_ = param1.errorDescription_;
         }
         this.addTextLine.dispatch(ChatMessage.make(Parameters.ERROR_CHAT_NAME,_loc2_));
         this.player.nextTeleportAt_ = 0;
      }
      
      private function handleBadKeyFailure(param1:Failure) : void
      {
         var _loc2_:String = LineBuilder.getLocalizedStringFromJSON(param1.errorDescription_);
         if(_loc2_ == "")
         {
            _loc2_ = param1.errorDescription_;
         }
         this.addTextLine.dispatch(ChatMessage.make(Parameters.ERROR_CHAT_NAME,_loc2_));
         this.retryConnection_ = false;
         gs_.closed.dispatch();
      }
      
      private function handleIncorrectVersionFailure(param1:Failure) : void
      {
         var _loc2_:Dialog = new Dialog(TextKey.CLIENT_UPDATE_TITLE,"",TextKey.CLIENT_UPDATE_LEFT_BUTTON,null,"/clientUpdate");
         _loc2_.setTextParams(TextKey.CLIENT_UPDATE_DESCRIPTION,{
            "client":Parameters.CLIENT_VERSION,
            "server":param1.errorDescription_
         });
         _loc2_.addEventListener(Dialog.LEFT_BUTTON,this.onDoClientUpdate);
         gs_.stage.addChild(_loc2_);
         this.retryConnection_ = false;
      }
      
      private function handleDefaultFailure(param1:Failure) : void
      {
         var _loc2_:String = LineBuilder.getLocalizedStringFromJSON(param1.errorDescription_);
         if(_loc2_ == "")
         {
            _loc2_ = param1.errorDescription_;
         }
         this.addTextLine.dispatch(ChatMessage.make(Parameters.ERROR_CHAT_NAME,_loc2_));
      }
      
      private function onDoClientUpdate(param1:Event) : void
      {
         var _loc2_:Dialog = param1.currentTarget as Dialog;
         _loc2_.parent.removeChild(_loc2_);
         gs_.closed.dispatch();
      }
      
      override public function isConnected() : Boolean
      {
         return serverConnection.isConnected();
      }
   }
}
