-- ============================================================================
-- DeltaTradeHub（三角洲/塔科夫交易行）数据库初始化脚本
--
-- 执行时机：站点首次启动时由 App_Start/DatabaseInitializer.cs 自动执行：
--   1) 连接串里指定的数据库不存在时先自动建库；
--   2) 库中还没有 Users 表时执行本脚本，建表并写入演示数据。
-- 也可以手动执行：先在 SSMS 里选中 DeltaTradeHubDB 数据库，再运行本脚本。
--
-- 说明：
--   * 本脚本按“空库”设计，所有建表和插入都带存在性判断，重复执行不会重复插入；
--   * sysdiagrams 是 SSMS 生成 E-R 图时的系统表，代码未使用，这里不创建；
--   * 演示账号密码均为 123456（SHA256 存储），正式使用请立即修改。
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. 用户表
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'Users', N'U') IS NULL
BEGIN
    CREATE TABLE Users (
        UserId          INT IDENTITY(1,1) NOT NULL,
        Username        NVARCHAR(50)  NOT NULL,
        PasswordHash    NVARCHAR(128) NOT NULL,
        Email           NVARCHAR(100) NOT NULL,
        Balance         DECIMAL(18,2) NOT NULL CONSTRAINT DF_Users_Balance      DEFAULT ((5000.00)),
        AvatarUrl       NVARCHAR(255) NULL,
        RegisterDate    DATETIME      NOT NULL CONSTRAINT DF_Users_RegisterDate DEFAULT (GETDATE()),
        LastLoginDate   DATETIME      NULL,
        IsActive        BIT           NOT NULL CONSTRAINT DF_Users_IsActive     DEFAULT ((1)),
        CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (UserId),
        CONSTRAINT UQ_Users_Username UNIQUE (Username)
    );
END
GO

-- ----------------------------------------------------------------------------
-- 2. 物品分类表
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'Categories', N'U') IS NULL
BEGIN
    CREATE TABLE Categories (
        CategoryId   INT IDENTITY(1,1) NOT NULL,
        CategoryName NVARCHAR(50) NOT NULL,
        IconClass    NVARCHAR(50) NULL,
        CONSTRAINT PK_Categories PRIMARY KEY CLUSTERED (CategoryId)
    );
END
GO

-- ----------------------------------------------------------------------------
-- 3. 物品表
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'Items', N'U') IS NULL
BEGIN
    CREATE TABLE Items (
        ItemId       INT IDENTITY(1,1) NOT NULL,
        CategoryId   INT            NOT NULL,
        ItemName     NVARCHAR(100)  NOT NULL,
        Description  NVARCHAR(500)  NOT NULL,
        Price        DECIMAL(18,2)  NOT NULL,
        Stock        INT            NOT NULL CONSTRAINT DF_Items_Stock      DEFAULT ((0)),
        Rarity       NVARCHAR(20)   NULL     CONSTRAINT DF_Items_Rarity     DEFAULT (N'Common'),
        ImageUrl     NVARCHAR(255)  NULL,
        CreateDate   DATETIME       NOT NULL CONSTRAINT DF_Items_CreateDate DEFAULT (GETDATE()),
        IsAvailable  BIT            NOT NULL CONSTRAINT DF_Items_IsAvailable DEFAULT ((1)),
        CONSTRAINT PK_Items PRIMARY KEY CLUSTERED (ItemId),
        CONSTRAINT FK_Items_Categories FOREIGN KEY (CategoryId) REFERENCES Categories (CategoryId)
    );
END
GO

-- ----------------------------------------------------------------------------
-- 4. 库存表
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'Inventory', N'U') IS NULL
BEGIN
    CREATE TABLE Inventory (
        InventoryId  INT IDENTITY(1,1) NOT NULL,
        UserId       INT      NOT NULL,
        ItemId       INT      NOT NULL,
        Quantity     INT      NOT NULL,
        AcquireDate  DATETIME NOT NULL CONSTRAINT DF_Inventory_AcquireDate DEFAULT (GETDATE()),
        CONSTRAINT PK_Inventory PRIMARY KEY CLUSTERED (InventoryId),
        CONSTRAINT UC_UserItem UNIQUE (UserId, ItemId),
        CONSTRAINT FK_Inventory_Users FOREIGN KEY (UserId) REFERENCES Users (UserId),
        CONSTRAINT FK_Inventory_Items FOREIGN KEY (ItemId) REFERENCES Items (ItemId)
    );
END
GO

-- ----------------------------------------------------------------------------
-- 5. 交易记录表
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'Transactions', N'U') IS NULL
BEGIN
    CREATE TABLE Transactions (
        TransactionId   INT IDENTITY(1,1) NOT NULL,
        UserId          INT           NOT NULL,
        ItemId          INT           NOT NULL,
        Quantity        INT           NOT NULL,
        UnitPrice       DECIMAL(18,2) NOT NULL,
        TotalAmount     DECIMAL(18,2) NOT NULL,
        TransactionDate DATETIME      NOT NULL CONSTRAINT DF_Transactions_TransactionDate DEFAULT (GETDATE()),
        Status          NVARCHAR(20)  NULL     CONSTRAINT DF_Transactions_Status          DEFAULT (N'Completed'),
        CONSTRAINT PK_Transactions PRIMARY KEY CLUSTERED (TransactionId),
        CONSTRAINT FK_Transactions_Users FOREIGN KEY (UserId) REFERENCES Users (UserId),
        CONSTRAINT FK_Transactions_Items FOREIGN KEY (ItemId) REFERENCES Items (ItemId)
    );
END
GO

-- ----------------------------------------------------------------------------
-- 6. 购物车表
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'Cart', N'U') IS NULL
BEGIN
    CREATE TABLE Cart (
        CartId     INT IDENTITY(1,1) NOT NULL,
        UserId     INT      NOT NULL,
        ItemId     INT      NOT NULL,
        Quantity   INT      NOT NULL,
        AddDate    DATETIME NOT NULL CONSTRAINT DF_Cart_AddDate DEFAULT (GETDATE()),
        CONSTRAINT PK_Cart PRIMARY KEY CLUSTERED (CartId),
        CONSTRAINT FK_Cart_Users FOREIGN KEY (UserId) REFERENCES Users (UserId),
        CONSTRAINT FK_Cart_Items FOREIGN KEY (ItemId) REFERENCES Items (ItemId)
    );
END
GO

-- ----------------------------------------------------------------------------
-- 7. 求购表
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'BuyOrders', N'U') IS NULL
BEGIN
    CREATE TABLE BuyOrders (
        OrderId     INT IDENTITY(1,1) NOT NULL,
        UserId      INT           NOT NULL,
        ItemId      INT           NOT NULL,
        Quantity    INT           NOT NULL,
        Price       DECIMAL(18,2) NOT NULL,
        Status      NVARCHAR(20)  NULL     CONSTRAINT DF_BuyOrders_Status     DEFAULT (N'Active'),
        CreateDate  DATETIME      NOT NULL CONSTRAINT DF_BuyOrders_CreateDate DEFAULT (GETDATE()),
        ExpireDate  DATETIME      NULL,
        CONSTRAINT PK_BuyOrders PRIMARY KEY CLUSTERED (OrderId),
        CONSTRAINT FK_BuyOrders_Users FOREIGN KEY (UserId) REFERENCES Users (UserId),
        CONSTRAINT FK_BuyOrders_Items FOREIGN KEY (ItemId) REFERENCES Items (ItemId)
    );
END
GO

-- ----------------------------------------------------------------------------
-- 8. 挂售表
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'Listings', N'U') IS NULL
BEGIN
    CREATE TABLE Listings (
        ListingId   INT IDENTITY(1,1) NOT NULL,
        UserId      INT           NOT NULL,
        ItemId      INT           NOT NULL,
        Quantity    INT           NOT NULL,
        Price       DECIMAL(18,2) NOT NULL,
        Status      NVARCHAR(20)  NULL     CONSTRAINT DF_Listings_Status     DEFAULT (N'Active'),
        CreateDate  DATETIME      NOT NULL CONSTRAINT DF_Listings_CreateDate DEFAULT (GETDATE()),
        CONSTRAINT PK_Listings PRIMARY KEY CLUSTERED (ListingId),
        CONSTRAINT FK_Listings_Users FOREIGN KEY (UserId) REFERENCES Users (UserId),
        CONSTRAINT FK_Listings_Items FOREIGN KEY (ItemId) REFERENCES Items (ItemId)
    );
END
GO

-- ----------------------------------------------------------------------------
-- 9. 资讯表
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'News', N'U') IS NULL
BEGIN
    CREATE TABLE News (
        NewsId      INT IDENTITY(1,1) NOT NULL,
        Title       NVARCHAR(200) NOT NULL,
        Category    NVARCHAR(50)  NOT NULL,
        Author      NVARCHAR(100) NOT NULL,
        Source      NVARCHAR(100) NOT NULL,
        PublishDate DATETIME      NOT NULL,
        Summary     NVARCHAR(500) NOT NULL,
        ImageUrl    NVARCHAR(200) NULL,
        Content     NVARCHAR(MAX) NULL,
        ViewCount   INT           NOT NULL CONSTRAINT DF_News_ViewCount   DEFAULT ((0)),
        IsTop       BIT           NOT NULL CONSTRAINT DF_News_IsTop       DEFAULT ((0)),
        CreateDate  DATETIME      NOT NULL CONSTRAINT DF_News_CreateDate  DEFAULT (GETDATE()),
        CONSTRAINT PK_News PRIMARY KEY CLUSTERED (NewsId)
    );
END
GO

-- ----------------------------------------------------------------------------
-- 10. 充值申请表
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'RechargeOrders', N'U') IS NULL
BEGIN
    CREATE TABLE RechargeOrders (
        Id          INT IDENTITY(1,1) NOT NULL,
        UserId      INT           NOT NULL,
        Amount      DECIMAL(18,2) NOT NULL,
        Status      NVARCHAR(20)  NOT NULL,
        CreateTime  DATETIME      NOT NULL,
        ApproveTime DATETIME      NULL,
        Remark      NVARCHAR(200) NULL,
        CONSTRAINT PK_RechargeOrders PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_RechargeOrders_Users FOREIGN KEY (UserId) REFERENCES Users (UserId)
    );
END
GO

-- ----------------------------------------------------------------------------
-- 11. 系统设置表
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'SystemSettings', N'U') IS NULL
BEGIN
    CREATE TABLE SystemSettings (
        Id           INT IDENTITY(1,1) NOT NULL,
        SettingKey   NVARCHAR(100) NOT NULL,
        SettingValue NVARCHAR(MAX) NOT NULL,
        Description  NVARCHAR(200) NULL,
        CONSTRAINT PK_SystemSettings PRIMARY KEY CLUSTERED (Id)
    );
END
GO

-- ----------------------------------------------------------------------------
-- 12. CS2 饰品行情表（后台行情数据，页面暂未使用）
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'cs2_items', N'U') IS NULL
BEGIN
    CREATE TABLE cs2_items (
        id           INT IDENTITY(1,1) NOT NULL,
        item_name    VARCHAR(255)  NOT NULL,
        item_type    VARCHAR(50)   NULL,
        rarity       VARCHAR(50)   NULL,
        quality      VARCHAR(50)   NULL,
        price        DECIMAL(10,2) NOT NULL,
        stock        INT           NULL CONSTRAINT DF_cs2_items_stock       DEFAULT ((0)),
        img_url      VARCHAR(500)  NULL,
        float_value  DECIMAL(8,7)  NULL,
        create_time  DATETIME      NULL CONSTRAINT DF_cs2_items_create_time DEFAULT (GETDATE()),
        update_time  DATETIME      NULL CONSTRAINT DF_cs2_items_update_time DEFAULT (GETDATE()),
        CONSTRAINT PK_cs2_items PRIMARY KEY CLUSTERED (id)
    );
END
GO

-- ============================================================================
-- 演示数据
-- ============================================================================

-- 分类（6 个）
IF NOT EXISTS (SELECT 1 FROM Categories)
BEGIN
    INSERT INTO Categories (CategoryName, IconClass) VALUES
        (N'突击步枪', N'fas fa-gun'),
        (N'手枪',     N'fas fa-crosshairs'),
        (N'装备',     N'fas fa-shield-alt'),
        (N'医疗品',   N'fas fa-medkit'),
        (N'配件',     N'fas fa-cog'),
        (N'近战武器', N'fas fa-fist-raised');
END
GO

-- 演示用户（密码均为 123456，SHA256 小写十六进制）
IF NOT EXISTS (SELECT 1 FROM Users)
BEGIN
    INSERT INTO Users (Username, PasswordHash, Email, Balance, LastLoginDate, IsActive) VALUES
        (N'DeltaOperator', N'8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'operator@example.com', 5000.00,  DATEADD(DAY, -1, GETDATE()), 1),
        (N'SniperWolf',    N'8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'sniper@example.com',   12800.00, DATEADD(DAY, -2, GETDATE()), 1),
        (N'MedicRush',     N'8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'medic@example.com',    3200.00,  DATEADD(DAY, -3, GETDATE()), 1),
        (N'admin',         N'8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'admin@example.com',    999999.00, NULL, 1);
END
GO

-- 物品（27 件，图片使用仓库内 img/items/ 下的本地图片）
IF NOT EXISTS (SELECT 1 FROM Items)
BEGIN
    INSERT INTO Items (CategoryId, ItemName, Description, Price, Stock, Rarity, ImageUrl) VALUES
        (1, N'AK-47 | 血腥运动',    N'CS2 热门步枪皮肤，久经沙场，性价比高',      1280.00,  47, N'field_tested',  N'/img/items/2.png'),
        (1, N'AK-47 | 皇后',        N'CS2 稀有步枪皮肤，崭新出厂，收藏级',        3680.00,  12, N'factory_new',   N'/img/items/3.png'),
        (1, N'AK-47 | 霓虹革命',    N'CS2 经典步枪皮肤，略有磨损',                899.00,   60, N'minimal_wear',  N'/img/items/4.png'),
        (1, N'M4A4 | 龙王',         N'CS2 顶级步枪皮肤，略有磨损，稀有款',        2880.00,  19, N'minimal_wear',  N'/img/items/5.png'),
        (1, N'M4A4 | 死寂空间',     N'CS2 冷门优质皮肤，破损不堪，价格实惠',      499.00,   80, N'well_worn',     N'/img/items/6.png'),
        (1, N'M4A1-S | 印花集',     N'CS2 热门步枪皮肤，崭新出厂',                1980.00,  25, N'factory_new',   N'/img/items/7.png'),
        (1, N'M4A1-S | 暴怒野兽',   N'CS2 性价比步枪皮肤，战痕累累',              299.00,  100, N'battle_scarred', N'/img/items/8.png'),
        (1, N'AK-47 | 阿努比斯军团', N'CS2 冷门皮肤，久经沙场',                    399.00,   70, N'field_tested',  N'/img/items/9.png'),
        (1, N'AWP | 二西莫夫',      N'CS2 顶级狙击皮肤，崭新出厂，收藏必备',      3680.00,  14, N'factory_new',   N'/img/items/10.png'),
        (1, N'AWP | 野火',          N'CS2 热门狙击皮肤，略有磨损',                2280.00,  18, N'minimal_wear',  N'/img/items/11.png'),
        (1, N'AWP | 浮生如梦',      N'CS2 稀有狙击皮肤，久经沙场',                1880.00,  22, N'field_tested',  N'/img/items/12.png'),
        (1, N'AWP | 渐变之色',      N'CS2 性价比狙击皮肤，破损不堪',              599.00,   90, N'well_worn',     N'/img/items/13.png'),
        (2, N'格洛克18 | 渐变之色', N'CS2 热门手枪皮肤，破损不堪',                899.00,   30, N'well_worn',     N'/img/items/14.png'),
        (2, N'沙漠之鹰 | 深红之网', N'CS2 顶级手枪皮肤，略有磨损',                1680.00,  16, N'minimal_wear',  N'/img/items/15.png'),
        (2, N'USP-S | 脑洞大开',    N'CS2 经典手枪皮肤，崭新出厂',                799.00,   40, N'factory_new',   N'/img/items/16.png'),
        (2, N'FN57 | 都市危机',     N'CS2 性价比手枪皮肤，战痕累累',              199.00,  120, N'battle_scarred', N'/img/items/17.png'),
        (6, N'蝴蝶刀 | 多普勒',     N'CS2 顶级刀具，战痕累累，收藏级',            8880.00,   8, N'battle_scarred', N'/img/items/18.png'),
        (6, N'折叠刀 | 渐变大理石', N'CS2 稀有刀具，崭新出厂',                    6880.00,   5, N'factory_new',   N'/img/items/19.png'),
        (6, N'爪子刀 | 黑色魅影',   N'CS2 热门刀具，略有磨损',                    7280.00,   6, N'minimal_wear',  N'/img/items/20.png'),
        (6, N'弯刀 | 屠夫',         N'CS2 性价比刀具，久经沙场',                  2880.00,  10, N'field_tested',  N'/img/items/21.png'),
        (1, N'MP9 | 富士山',        N'CS2 热门冲锋枪皮肤，破损不堪',              399.00,   85, N'well_worn',     N'/img/items/22.png'),
        (1, N'MAC-10 | 霓虹骑士',   N'CS2 经典冲锋枪皮肤，战痕累累',              299.00,   95, N'battle_scarred', N'/img/items/23.png'),
        (1, N'XM1014 | 蓝色钢网',   N'CS2 喷子皮肤，久经沙场',                    499.00,   75, N'field_tested',  N'/img/items/24.png'),
        (3, N'防弹衣',              N'基础防护装备，可抵挡部分子弹伤害',          650.00,   50, N'Common',        N'/img/items/default.png'),
        (3, N'战术头盔',            N'与防弹衣搭配使用，提供头部防护',            780.00,   35, N'Common',        N'/img/items/default.png'),
        (4, N'医疗包',              N'使用后恢复大量生命值',                       50.00,  200, N'Common',        N'/img/items/default.png'),
        (5, N'红点瞄准镜',          N'提升瞄准速度的战术配件',                    220.00,   60, N'Common',        N'/img/items/default.png');
END
GO

-- 我的库存（演示）
IF NOT EXISTS (SELECT 1 FROM Inventory)
BEGIN
    INSERT INTO Inventory (UserId, ItemId, Quantity) VALUES
        (1, 1,  1),
        (1, 9,  1),
        (2, 17, 2),
        (3, 26, 1);
END
GO

-- 购物车（演示）
IF NOT EXISTS (SELECT 1 FROM Cart)
BEGIN
    INSERT INTO Cart (UserId, ItemId, Quantity) VALUES
        (1, 2, 1),
        (1, 21, 2);
END
GO

-- 我的挂售（演示）
IF NOT EXISTS (SELECT 1 FROM Listings)
BEGIN
    INSERT INTO Listings (UserId, ItemId, Quantity, Price, Status) VALUES
        (2, 3,  1, 3600.00, N'Active'),
        (2, 11, 1, 2200.00, N'Active'),
        (3, 27, 1, 210.00,  N'Active');
END
GO

-- 求购单（演示）
IF NOT EXISTS (SELECT 1 FROM BuyOrders)
BEGIN
    INSERT INTO BuyOrders (UserId, ItemId, Quantity, Price, Status, ExpireDate) VALUES
        (1, 10, 1, 3500.00, N'Active', DATEADD(DAY, 7, GETDATE())),
        (3, 15, 1, 1550.00, N'Active', DATEADD(DAY, 7, GETDATE()));
END
GO

-- 交易记录（演示 50 条）
IF NOT EXISTS (SELECT 1 FROM Transactions)
BEGIN
    DECLARE @i INT = 1;
    WHILE @i <= 50
    BEGIN
        INSERT INTO Transactions (UserId, ItemId, Quantity, UnitPrice, TotalAmount, TransactionDate, Status)
        SELECT 1 + (@i % 3), 1 + (@i % 27), 1, Price, Price, DATEADD(DAY, -(@i % 30), GETDATE()), N'Completed'
        FROM Items WHERE ItemId = 1 + (@i % 27);
        SET @i = @i + 1;
    END
END
GO

-- 资讯（演示 3 条，图片使用仓库内 img/ 下的本地图片）
IF NOT EXISTS (SELECT 1 FROM News)
BEGIN
    INSERT INTO News (Title, Category, Author, Source, PublishDate, Summary, ImageUrl, Content, ViewCount, IsTop) VALUES
        (N'科隆 Major 2026 赛程公布，32 支战队争夺 125 万美元奖金',
         N'CS2', N'编辑部', N'本站原创', DATEADD(DAY, -2, GETDATE()),
         N'IEM 科隆 Major 2026 将于 6 月 2 日开赛，这是今年首个 Major，32 支战队将争夺 125 万美元奖金池。',
         N'/img/news1.jpg',
         N'<p>IEM 科隆 Major 2026 将于 6 月 2 日正式开赛，小组赛率先打响，这是今年首个 Major 赛事。</p><p>本届赛事共有 32 支战队参赛，总奖金 125 万美元。小组赛采用瑞士轮赛制，淘汰赛阶段为单败淘汰。</p><p>中国战队 TYLOO 与 Lynn Vision 均已获得参赛资格，期待他们的表现。</p>',
         0, 1),
        (N'饰品市场观察：多品类价格回稳，成交量有所回升',
         N'CS2', N'市场观察', N'本站原创', DATEADD(DAY, -5, GETDATE()),
         N'经历了一段时间的降价潮后，本周主流饰品价格趋于平稳，部分热门皮肤成交量开始回升。',
         N'/img/news7.jpg',
         N'<p>在过去的一个月里，受开箱数量增加影响，主流饰品价格整体走低。</p><p>本周开始，市场出现企稳迹象：热门步枪与狙击皮肤的价格波动收窄，成交量较上周有所回升。</p><p>分析认为，随着 Major 临近，选手印花与贴纸相关饰品可能迎来一波需求。交易请注意风险，理性入手。</p>',
         0, 0),
        (N'赛后采访：ropz 谈队伍状态与 Major 目标',
         N'CS2', N'转载', N'HLTV', DATEADD(DAY, -7, GETDATE()),
         N'在 IEM 亚特兰大站结束后，ropz 接受采访，谈到了队伍的开局慢热、失误调整以及为科隆 Major 做的准备。',
         N'/img/news9.jpg',
         N'<p>在 IEM 亚特兰大站的比赛中，队伍开局阶段状态略慢，但随后逐渐找回节奏。</p><p>ropz 表示，队伍不会因为过去的成绩而自满，接下来会针对 Major 做更充分的准备。</p>',
         0, 0);
END
GO

-- 充值申请（演示：一条待审核）
IF NOT EXISTS (SELECT 1 FROM RechargeOrders)
BEGIN
    INSERT INTO RechargeOrders (UserId, Amount, Status, CreateTime, Remark) VALUES
        (2, 100.00, N'Pending', DATEADD(HOUR, -3, GETDATE()), N'演示数据：等待管理员审核');
END
GO

-- 系统设置（演示值，正式部署请改成自己的信息）
IF NOT EXISTS (SELECT 1 FROM SystemSettings)
BEGIN
    INSERT INTO SystemSettings (SettingKey, SettingValue, Description) VALUES
        (N'PlatformName',      N'塔科夫交易行',  N'平台名称'),
        (N'CustomerService',   N'service@example.com', N'客服邮箱'),
        (N'TransactionFeeRate', N'0.05',          N'交易手续费率（如 0.05 表示 5%）'),
        (N'AdminNotice',       N'欢迎来到管理后台', N'后台登录提示');
END
GO
