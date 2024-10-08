// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Profile} from "./Profile.sol";
import {Token} from "./Token.sol";
import {Item} from "./Item.sol";
import {Potion} from "./Potion.sol";
import {Raffle} from "./Raffle.sol";
import {CraftSystem} from "./CraftSystem.sol";
import {IERC4626} from "./IERC4626.sol";

contract World is Raffle, Ownable, ReentrancyGuard {
    // Data Structures
    enum QuestType {
        DAILY_CHECK_IN,
        PLAY_MINIGAME,
        CRAFT
    }

    enum ExchangeType {
        BUY,
        SELL
    }

    enum BlockType {
        STONE,
        IRON,
        GOLD,
        DIAMOND
    }

    struct Player {
        uint32 tokenId;
        uint16 score;
        uint8 streak;
        uint16 ticket;
        uint8 stamina;
        uint8 hp;
        uint256 lastCheckIn;
        uint256 lastRaffle;
        uint256 lastDoCraft;
        uint256 lastResetPlayer;
    }
    struct PlayerInventory {
        BlockType[] blocks;
        uint256[] blockQuantities;
    }
    struct Quest {
        string name;
        string description;
        uint256 reward;
        QuestType questType;
    }
    struct GameItem {
        string name;
        string description;
        uint256 price;
    }
    // Data Structures

    // External Contract
    address public profile; // Profile
    address public token; // Token
    address public item; // Item
    address public craft; // Craft System
    address public potion; // Potion
    address public registry; // Registry
    address public account; // Token Bound Account
    address public vault; // Vault
    uint256 public chainId;
    // External Contract

    // Game data
    mapping(address => Player) public players;
    mapping(uint256 => Quest) public quests;
    mapping(uint256 => GameItem) public gameItems;

    uint256 public questCount = 0;
    uint256 public itemCount = 0;
    uint256 public marketfees = 20; // 20%

    uint256 public constant CHECK_IN_WINDOW = 24 hours;
    uint256 public constant DENOMINATOR = 10 ** 18;

    uint8 public constant NORMAL_DROP = 30; // 30% Chance
    uint8 public constant RARE_DROP = 10; // 10% Chance
    uint8 public constant EPIC_DROP = 5; // 5% Chance 
    // Game data

    // Events
    event PlayerCreated(
        uint256 tokenId,
        address owner,
        uint256 timestamp
    );
    event PlayerUpdated(
        uint256 tokenId,
        address owner,
        uint256 timestamp
    );
    event PlayerDeleted(
        uint256 tokenId,
        address owner,
        uint256 timestamp
    );
    event QuestCreated(
        uint256 questId,
        uint256 reward,
        QuestType questType,
        uint256 timestamp
    );
    event QuestUpdated(
        uint256 questId,
        uint256 reward,
        QuestType questType,
        uint256 timestamp
    );
    event GameItemCreated(
        uint256 itemId,
        uint256 price,
        uint256 timestamp
    );
     event GameItemUpdated(
        uint256 itemId,
        uint256 price,
        uint256 timestamp
    );
    event CheckedIn(address indexed user, uint256 timestamp, uint256 newStreak);
    event RaffleResulted(address indexed user, uint256 timestamp, bool result);
    event MarketFeesUpdated(
        uint256 fees,
        uint256 timestamp
    );
    // Events

    // Modifiers
    modifier onlyUser() {
        require(Profile(profile).balanceOf(_msgSender()) > 0, "Only user can call this function");
        _;
    }
    modifier onlyTokenOwner(uint32 _tokenId) {
        require(Profile(profile).ownerOf(_tokenId) == _msgSender(), "Only owner of the token can exchange item");
        _;
    }
    modifier onlyPlayer() {
        require(players[_msgSender()].tokenId > 0, "Player not found");
        _;
    }
    // Modifiers

    // constructor
    constructor(address _initialOwner) {
        transferOwnership(_initialOwner);
    }
    // constructor
    
    // Player functions
    function _resetPlayer() internal {
        players[_msgSender()].stamina = 100;
        players[_msgSender()].hp = 10;
        players[_msgSender()].lastResetPlayer = block.timestamp;
    }
    // Player functions

    // Spawn functions
    function spawn(uint32 _tokenId) external onlyUser onlyTokenOwner(_tokenId) {
        require(block.timestamp >=players[_msgSender()].lastResetPlayer  + CHECK_IN_WINDOW, "Too early for next reset player");
        _resetPlayer();
    }
    // Spawn functions

    // Mine functions
    function _isBlockValid(uint256 x, uint256 y, uint256 z) internal view returns (bool) {
        // TODO: add more logic to validate the block
        return true;
    }

    function _calculateDrop(uint256 x, uint256 y, uint256 z) internal view returns (uint256) {
        require(_isBlockValid(x, y, z), "Invalid block");
        uint256 randomSeed = (uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, x, y, z))) % 100);
        uint256 drop = 0;
        if(randomSeed < EPIC_DROP) {
            drop = 100;
        } else if(randomSeed < RARE_DROP) {
            drop = 50;
        } else if(randomSeed < NORMAL_DROP) {
            drop = 10;
        }
        return drop;
    }

    // Player functions
    function createPlayer(uint32 _tokenId) external onlyUser onlyTokenOwner(_tokenId) {
        players[_msgSender()] = Player(_tokenId, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        emit PlayerCreated(_tokenId, _msgSender(), block.timestamp);
    }

    function getPlayer(address _player) external view returns (Player memory) {
        return players[_player];
    }
    // Player functions

    // Mine functions
    function mine(uint32 _tokenId, uint256 x, uint256 y, uint256 z) external onlyUser onlyTokenOwner(_tokenId) {
        require(_isBlockValid(x, y, z), "Invalid block");
        require(players[_msgSender()].stamina > 0, "Not enough stamina");
        players[_msgSender()].stamina -= 1;
        uint256 drop = _calculateDrop(x, y, z);
        _distributeRewardandScore(_tokenId, drop);
    }
    // Mine functions

    // Build functions
    function build(uint32 _tokenId, uint256 x, uint256 y, uint256 z) external onlyUser onlyTokenOwner(_tokenId) {
        require(_isBlockValid(x, y, z), "Invalid block");
        require(players[_msgSender()].stamina > 0, "Not enough stamina");
        players[_msgSender()].stamina -= 1;
    }
    // Build functions

    // consumePotion functions
    function consumePotion(uint32 _tokenId, uint256 _potionId) external onlyUser onlyTokenOwner(_tokenId) {
        // address tokenBoundAccount = _getTokenBoundAccount(_tokenId);
        require(Potion(potion).balanceOf(_msgSender(), _potionId) > 0, "Potion Token is not enough to consume potion");
        Potion(potion).burn(_msgSender(), _potionId, 1);
        if(_potionId == 0) {
            players[_msgSender()].stamina += 10;
        } else {
            players[_msgSender()].hp += 1;
        }
    }
    // consumePotion functions

    // Market functions
    function setMarketFees(uint256 fees) external onlyOwner {
        require(fees > 0 && fees <= 100, "feed require between 0 - 100");
        marketfees = fees;
        emit MarketFeesUpdated(fees, block.timestamp);
    }
    // Market functions

    // Exchange functions
    function exchangeItem(uint32 _tokenId, uint256 _itemId, ExchangeType exchangeType) external onlyUser onlyTokenOwner(_tokenId) nonReentrant {
        uint256 price = _getItemPrice(_itemId);

        if(exchangeType == ExchangeType.BUY) {
            require(Token(token).balanceOf(_msgSender()) >= price, "Cube Token is not enough to buy item");
            Token(token).approve(address(this), price);
            Token(token).transferFrom(_msgSender(), address(this), price);
            Item(item).mint(_msgSender(), _itemId, 1);
        } else {
            require(Item(item).balanceOf(_msgSender(), _itemId) > 0, "Item Token is not enough to sell item");
            Item(item).burn(_msgSender(), _itemId, 1);
            Token(token).transfer(_msgSender(), (price * (100 - marketfees)) / 100);
        }
    }

    function _getItemPrice(uint256 _itemId) internal view returns (uint256) {
        require(gameItems[_itemId].price > 0, "Item not found");
        return  gameItems[_itemId].price * DENOMINATOR;
    }
    // Exchange functions

    // Quest functions
    function doQuest(uint32 _tokenId, uint256 _questId, uint256 _data) external onlyUser onlyTokenOwner(_tokenId) {
        if(quests[_questId].questType == QuestType.DAILY_CHECK_IN) {
            // Quest 1: Daily check-in
            _dailyCheckIn(_tokenId, quests[_questId].reward);
        } else if(quests[_questId].questType == QuestType.PLAY_MINIGAME) {
            // Quest 3: Play Mini game
            _dailyPlayMinigame(_tokenId, quests[_questId].reward, _data);
        } else if(quests[_questId].questType == QuestType.CRAFT) {
            // Quest 2: craft
            _doCraft(_tokenId, quests[_questId].reward, _data);
        } 
        else {
            revert("Invalid quest id");
        }
    }

    function doDeposit(uint32 _tokenId, uint256 _amount) external onlyUser onlyTokenOwner(_tokenId) {
        require(_amount > 0, "Amount must be greater than 0");
        require(Token(token).transferFrom(_msgSender(), address(this), _amount), "Transfer failed");
        // Approve the vault to spend the asset on behalf of the World contract
        require(Token(token).approve(address(vault), _amount), "Approve failed");
        // Token(token).approve(vault, _amount);
        uint256 share = IERC4626(vault).deposit(_amount, _msgSender());

        if(share > 0) {
            players[_msgSender()].ticket += 1;
        }
    }

    function _distributeRewardandScore(uint32 _tokenId, uint256 _reward) internal {
        // address tokenBoundAccount = _getTokenBoundAccount(_tokenId);
        Token(token).mint(_msgSender(), _reward * DENOMINATOR);
    }

    function _dailyCheckIn(uint32 _tokenId, uint256 _reward) internal {
        Player storage userCheckInInfo = players[_msgSender()];
        require(block.timestamp >= userCheckInInfo.lastCheckIn + CHECK_IN_WINDOW, "Too early for next check-in");

        if (block.timestamp > userCheckInInfo.lastCheckIn + (CHECK_IN_WINDOW * 2)) {
            // Reset the streak if checking in after the 48-hour window
            userCheckInInfo.streak = 1;
        } else {
            // Increment streak if within the 24-48 hour window
            userCheckInInfo.streak++;
        }

        _distributeRewardandScore(_tokenId, _reward);

        userCheckInInfo.lastCheckIn = block.timestamp;
        emit CheckedIn(_msgSender(), block.timestamp, userCheckInInfo.streak);
    }

    function _dailyPlayMinigame(uint32 _tokenId, uint256 _reward, uint256 _guess) internal {
        require(players[_msgSender()].ticket > 0 , "No ticket is avaliabe");
        uint256 r = _enterRaffle();
        players[_msgSender()].ticket = players[_msgSender()].ticket - 1;
       // TODO: deposit in vault to raffle ticket
       // TODO: 100 $CUBE = 1 ticket
       // TODO: doeposit CUBE will be prize pool
        if(r == _guess) {
            _distributeRewardandScore(_tokenId, _reward);
            emit RaffleResulted(_msgSender(), block.timestamp, true);
        } else {
            emit RaffleResulted(_msgSender(), block.timestamp, false);
        }
    }

    function _doCraft(uint32 _tokenId, uint256 _reward, uint256 _recipeId) internal {
        (bool success, ) = CraftSystem(craft).craftItem(_recipeId, _msgSender());
        if(success) {
            _distributeRewardandScore(_tokenId, _reward);
        }
    }

    function checkCurrentQuestStatus() public view returns (bool isCheckIn, bool isPlayMinigame, bool lastDoCraft){
        Player storage userCheckInInfo = players[_msgSender()];
        isCheckIn = false;
        isPlayMinigame = false;
        lastDoCraft = false;

        if(block.timestamp >= userCheckInInfo.lastCheckIn - CHECK_IN_WINDOW && block.timestamp < userCheckInInfo.lastCheckIn + CHECK_IN_WINDOW) {
            isCheckIn = true;
        }
        if(block.timestamp < userCheckInInfo.lastRaffle - CHECK_IN_WINDOW && block.timestamp < userCheckInInfo.lastRaffle + CHECK_IN_WINDOW) {
            isPlayMinigame = true;
        }
        if(block.timestamp < userCheckInInfo.lastDoCraft - CHECK_IN_WINDOW && block.timestamp < userCheckInInfo.lastDoCraft + CHECK_IN_WINDOW) {
            lastDoCraft = true;
        }
        
        return (isCheckIn, isPlayMinigame, lastDoCraft);
    }

    function getQuests() external view returns (Quest[] memory) {
        Quest[] memory questArray = new Quest[](questCount);
        for (uint256 i = 0; i < questCount; i++) {
            questArray[i] = quests[i];
        }
        return questArray;
    }
    // Quest functions

    // Admin functions
    // config world
    function setProfile(address _profile) public onlyOwner {
        profile = _profile;
    }

    function setToken(address _token) public onlyOwner {
        token = _token;
    }

    function setItem(address _item) public onlyOwner {
        item = _item;
    }

    function setPotion(address _potion) public onlyOwner {
        potion = _potion;
    }

    function setCraft(address _craft) public onlyOwner {
        craft = _craft;
    }

    function setVault(address _vault) public onlyOwner {
        vault = _vault;
    }

    function configTokenBound(address _registry, address _account, uint256 _chainId) public onlyOwner {
        registry = _registry;
        account = _account;
        chainId = _chainId;
    }
    // config world

    // Quest functions
    function createQuest(string memory _name, string memory _description, uint256 _reward, QuestType _questType) public onlyOwner {
        quests[questCount] = Quest(_name, _description, _reward, _questType);
        emit QuestCreated(questCount, _reward, _questType, block.timestamp);
        questCount++;
    }

    function setQuest(uint256 _questId, string memory _name, string memory _description, uint256 _reward, QuestType _questType) public onlyOwner {
        quests[_questId] = Quest(_name, _description, _reward, _questType);
        emit QuestUpdated(_questId, _reward, _questType, block.timestamp);
    }
    // Quest functions

    // Player functions
    function deletePlayer(address _player) public onlyOwner {
        uint32 _tokenId = players[_player].tokenId;
        delete players[_player];
        emit PlayerDeleted(_tokenId, _player, block.timestamp);
    }
    // Player functions

    // Exchange functions
    function createItem(uint256 _itemId, string memory _name, string memory _description, uint256 _price) public onlyOwner {
        gameItems[_itemId] = GameItem(_name, _description, _price);
        emit GameItemCreated(_itemId, _price, block.timestamp);
        itemCount++;
    }

    function setItemPrice(uint256 _itemId, string memory _name, string memory _description, uint256 _price) public onlyOwner {
        gameItems[_itemId] = GameItem(_name, _description, _price);
        emit GameItemCreated(_itemId, _price, block.timestamp);
    }
    // Exchange functions

    // Craft System functions
    function addRecipe(uint256[] memory _inputs, uint256[] memory _quantities, uint256 _result) public onlyOwner {
        CraftSystem(craft).addReccipe(_inputs, _quantities, _result);
    }

    function setRecipe(uint256 _recipeId, uint256[] memory _inputs, uint256[] memory _quantities, uint256 _result) public onlyOwner {
        CraftSystem(craft).setRecipe(_recipeId, _inputs, _quantities, _result);
    }

    function getRecipe(uint256 _recipeId) public view returns (CraftSystem.Recipes memory) {
        return CraftSystem(craft).getRecipe(_recipeId);
    }

    function getAllRecipes() public view returns (CraftSystem.Recipes[] memory) {
        return CraftSystem(craft).getAllRecipes();
    }

    function addItems(uint256 _id, CraftSystem.ItemType _itemType) public onlyOwner {
        CraftSystem(craft).addItems(_id, _itemType);
    }

    function getItem(uint256 _itemId) public view returns (CraftSystem.Items memory) {
        return CraftSystem(craft).getItem(_itemId);
    }
    // Craft System functions
    // Admin functions
}