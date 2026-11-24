<%@ Page Title="专业市场" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Market.aspx.cs" Inherits="DeltaTradeHub.Market" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* 所有样式代码完全保留，与您原来的一模一样 */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        .top-nav-right { display: flex; align-items: center; gap: 20px; margin-left: auto; }
        .cart-icon-container { position: relative; cursor: pointer; color: white; font-size: 20px; }
        .cart-badge { position: absolute; top: -8px; right: -8px; background-color: #ff7e00; color: white; font-size: 12px; width: 18px; height: 18px; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
        .user-dropdown-container { position: relative; color: white; cursor: pointer; display: flex; align-items: center; gap: 8px; }
        .user-avatar { width: 32px; height: 32px; border-radius: 50%; background-color: #ff7e00; display: flex; align-items: center; justify-content: center; font-weight: bold; }
        .dropdown-arrow { font-size: 12px; transition: transform 0.2s ease; }
        .user-dropdown-container:hover .dropdown-arrow { transform: rotate(180deg); }
        .user-dropdown-panel { position: absolute; top: 40px; right: 0; width: 180px; background-color: white; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); z-index: 1000; display: none; }
        .user-dropdown-container:hover .user-dropdown-panel { display: block; }
        .dropdown-menu { list-style: none; padding: 8px 0; }
        .dropdown-menu-item { padding: 10px 16px; color: #1e293b; font-size: 14px; cursor: pointer; transition: background-color 0.2s; }
        .dropdown-menu-item:hover { background-color: #f8fafc; }
        .dropdown-menu-item a { color: inherit; text-decoration: none; display: block; }
        .buff-carousel { width: 100%; height: 160px; background: linear-gradient(135deg, #1e293b 0%, #334155 100%); border-radius: 12px; margin-bottom: 24px; position: relative; overflow: hidden; }
        .carousel-img { width: 100%; height: 100%; object-fit: cover; opacity: 0.85; }
        .carousel-text { position: absolute; top: 50%; left: 50px; transform: translateY(-50%); color: white; }
        .carousel-title { font-size: 24px; font-weight: 700; margin-bottom: 8px; }
        .carousel-subtitle { font-size: 14px; opacity: 0.8; }
        .market-container { display: flex; gap: 20px; max-width: 1200px; margin: 0 auto; }
        .filter-sidebar { width: 220px; background: white; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); padding: 16px; }
        .filter-title { font-size: 16px; font-weight: 600; color: #1e293b; margin-bottom: 16px; padding-bottom: 8px; border-bottom: 1px solid #f1f5f9; }
        .game-filter-list { list-style: none; }
        .game-filter-item { padding: 10px 8px; border-radius: 8px; margin-bottom: 4px; cursor: pointer; font-size: 14px; display: flex; align-items: center; gap: 8px; }
        .game-filter-item.active { background-color: #fff5ec; color: #ff7e00; font-weight: 500; }
        .game-filter-item:hover:not(.active) { background-color: #f8fafc; }
        .game-icon { width: 20px; height: 20px; border-radius: 4px; background-color: #e2e8f0; display: flex; align-items: center; justify-content: center; }
        .content-area { flex: 1; }
        .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        .section-title { font-size: 18px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 8px; }
        .section-title i { color: #ff7e00; }
        .section-more { font-size: 12px; color: #64748b; text-decoration: none; }
        .section-more:hover { color: #ff7e00; }
        .item-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; margin-bottom: 24px; }
        .item-card { background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 1px 2px rgba(0,0,0,0.06); transition: all 0.3s ease; cursor: pointer; position: relative; }
        .item-card:hover { transform: translateY(-4px); box-shadow: 0 8px 16px rgba(0,0,0,0.1); border-color: #ff7e00; }
        .item-img-container { width: 100%; height: 180px; background-color: #f8fafc; position: relative; overflow: hidden; }
        .item-img { width: 100%; height: 100%; object-fit: contain; padding: 16px; transition: transform 0.3s ease; }
        .item-card:hover .item-img { transform: scale(1.05); }
        .wear-tag { position: absolute; top: 8px; left: 8px; background: rgba(0,0,0,0.7); color: white; font-size: 10px; padding: 2px 6px; border-radius: 4px; }
        .sticker-tag { position: absolute; bottom: 8px; right: 8px; background: #ff7e00; color: white; font-size: 10px; padding: 2px 6px; border-radius: 4px; }
        .item-card-content { padding: 12px; }
        .item-name { font-size: 13px; font-weight: 500; color: #1e293b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-bottom: 4px; }
        .item-price { font-size: 16px; font-weight: 700; color: #ff7e00; margin-bottom: 4px; }
        .item-meta { display: flex; justify-content: space-between; font-size: 11px; color: #94a3b8; }
        .item-stock { color: #64748b; }
        .item-actions { display: flex; gap: 8px; margin-top: 8px; }
        .btn-buy { flex: 1; background-color: #ff7e00; color: white; border: none; border-radius: 6px; padding: 6px 0; font-size: 12px; font-weight: 600; cursor: pointer; transition: background-color 0.2s; }
        .btn-buy:hover { background-color: #e66900; }
        .btn-cart { flex: 1; background-color: #f8fafc; color: #1e293b; border: 1px solid #e2e8f0; border-radius: 6px; padding: 6px 0; font-size: 12px; cursor: pointer; transition: all 0.2s; }
        .btn-cart:hover { background-color: #f1f5f9; border-color: #cbd5e1; }
        .pagination { display: flex; justify-content: center; gap: 8px; margin: 24px 0; }
        .page-btn { width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; background-color: #f8fafc; color: #64748b; text-decoration: none; font-size: 14px; transition: all 0.2s; }
        .page-btn:hover { background-color: #e2e8f0; color: #1e293b; }
        .page-btn.active { background-color: #ff7e00; color: white; }
        .cart-drawer { position: fixed; top: 0; right: -400px; width: 400px; height: 100vh; background: white; box-shadow: -2px 0 12px rgba(0,0,0,0.1); z-index: 999; transition: right 0.3s ease; display: flex; flex-direction: column; }
        .cart-drawer.open { right: 0; }
        .cart-header { padding: 16px; border-bottom: 1px solid #f1f5f9; display: flex; justify-content: space-between; align-items: center; font-weight: 600; font-size: 16px; }
        .close-cart { cursor: pointer; font-size: 20px; color: #64748b; }
        .cart-body { flex: 1; overflow-y: auto; padding: 16px; }
        .cart-empty { text-align: center; padding: 40px 0; color: #94a3b8; font-size: 14px; }
        .cart-item { display: flex; gap: 12px; padding: 12px 0; border-bottom: 1px solid #f1f5f9; }
        .cart-item-img { width: 60px; height: 60px; border-radius: 8px; background-color: #f8fafc; overflow: hidden; }
        .cart-item-img img { width: 100%; height: 100%; object-fit: contain; }
        .cart-item-info { flex: 1; }
        .cart-item-name { font-size: 13px; font-weight: 500; margin-bottom: 4px; }
        .cart-item-price { font-size: 14px; color: #ff7e00; font-weight: 600; margin-bottom: 8px; }
        .cart-item-qty { display: flex; align-items: center; gap: 8px; }
        .qty-btn { width: 24px; height: 24px; border-radius: 4px; border: 1px solid #e2e8f0; background: #f8fafc; display: flex; align-items: center; justify-content: center; cursor: pointer; font-size: 12px; }
        .qty-input { width: 40px; height: 24px; text-align: center; border: 1px solid #e2e8f0; border-radius: 4px; font-size: 12px; }
        .cart-item-remove { color: #dc3545; font-size: 12px; cursor: pointer; margin-left: 8px; }
        .cart-footer { padding: 16px; border-top: 1px solid #f1f5f9; }
        .cart-total { display: flex; justify-content: space-between; font-size: 16px; font-weight: 700; margin-bottom: 16px; }
        .cart-total-price { color: #ff7e00; }
        .btn-checkout { width: 100%; background-color: #ff7e00; color: white; border: none; border-radius: 8px; padding: 12px 0; font-size: 14px; font-weight: 600; cursor: pointer; }
        .btn-checkout:hover { background-color: #e66900; }
        .overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 998 !important; display: none; }
        .overlay.show { display: block; }
        .loading { position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: rgba(0,0,0,0.7); color: white; padding: 12px 24px; border-radius: 8px; z-index: 1000; display: none; }
        .loading.show { display: block; }
    </style>

    <!-- 顶部栏（原有结构不变） -->
    <div class="top-nav-right">

    </div>

    <!-- 轮播广告位 -->
    <div class="buff-carousel">
        <img src="img/4.jpg" class="carousel-img" alt="网易UU远程">
        <div class="carousel-text">
            <div class="carousel-title">网易UU远程</div>
            <div class="carousel-subtitle">手机随时随地畅玩CS2</div>
        </div>
    </div>

    <!-- 市场主布局 -->
    <div class="market-container">
        <!-- 左侧筛选栏 -->
        <div class="filter-sidebar">
            <div class="filter-title">热门游戏</div>
            <ul class="game-filter-list">
                <li class="game-filter-item active" data-game="cs2"><div class="game-icon">CS</div><span>CS2（反恐精英）</span></li>
                <li class="game-filter-item" data-game="dota2"><div class="game-icon">D2</div><span>DOTA2</span></li>
                <li class="game-filter-item" data-game="pubg"><div class="game-icon">PG</div><span>绝地求生</span></li>
                <li class="game-filter-item" data-game="apex"><div class="game-icon">AP</div><span>APEX英雄</span></li>
            </ul>
        </div>

        <!-- 右侧内容区 -->
        <div class="content-area">
            <!-- 热门饰品板块 -->
            <div class="section">
                <div class="section-header">
                    <div class="section-title"><i>🔥</i> 热门饰品</div>
                    <a href="HotItems.aspx" class="section-more">更多 ></a>
                </div>
                <div class="item-grid">
                    <asp:Repeater ID="rptHotItems" runat="server">
                        <ItemTemplate>
                            <div class="item-card" data-itemid='<%# Eval("ItemId") %>'>
                                <div class="item-img-container">
                                    <img class="item-img" src='<%# string.IsNullOrEmpty(Eval("ImageUrl")?.ToString()) || !Eval("ImageUrl").ToString().StartsWith("/img/") ? "/img/items/default.png" : Eval("ImageUrl") %>' alt='<%# Eval("ItemName") %>' onerror="this.src='/img/items/default.png'">
                                    <div class="wear-tag"><%# GetWearText(Eval("Rarity").ToString()) %></div>
                                    <% if (new Random().Next(0, 2) == 1) { %>
                                        <div class="sticker-tag">印花×<%= new Random().Next(1, 4) %></div>
                                    <% } %>
                                </div>
                                <div class="item-card-content">
                                    <div class="item-name"><%# Eval("ItemName") %></div>
                                    <div class="item-price"><%# Eval("Price", "¥{0:N2}") %></div>
                                    <div class="item-meta">
                                        <div class="item-wear"><%# GetWearDesc(Eval("Rarity").ToString()) %></div>
                                        <div class="item-stock">库存: <%# Eval("Stock") %></div>
                                    </div>
                                    <div class="item-actions">
                                        <asp:Button ID="btnBuyHot" runat="server" CommandArgument='<%# Eval("ItemId") %>' Text="立即购买" CssClass="btn-buy" OnClick="DirectBuy_Click" />
                                        <asp:Button ID="btnCartHot" runat="server" CommandArgument='<%# Eval("ItemId") %>' Text="加入购物车" CssClass="btn-cart" OnClick="AddToCart_Click" />
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <div class="pagination">
                    <asp:Repeater ID="rptHotPagination" runat="server">
                        <ItemTemplate><a href='<%# Eval("Url") %>' class='page-btn <%# Eval("CssClass") %>'><%# Eval("Text") %></a></ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <!-- 最新上架板块 -->
            <div class="section">
                <div class="section-header">
                    <div class="section-title"><i>🆕</i> 最新上架</div>
                    <a href="NewItems.aspx" class="section-more">更多 ></a>
                </div>
                <div class="item-grid">
                    <asp:Repeater ID="rptNewItems" runat="server">
                        <ItemTemplate>
                            <div class="item-card" data-itemid='<%# Eval("ItemId") %>'>
                                <div class="item-img-container">
                                    <img class="item-img" src='<%# string.IsNullOrEmpty(Eval("ImageUrl")?.ToString()) || !Eval("ImageUrl").ToString().StartsWith("/img/") ? "/img/items/default.png" : Eval("ImageUrl") %>' alt='<%# Eval("ItemName") %>' onerror="this.src='/img/items/default.png'">
                                    <div class="wear-tag"><%# GetWearText(Eval("Rarity").ToString()) %></div>
                                    <% if (new Random().Next(0, 2) == 1) { %>
                                        <div class="sticker-tag">印花×<%= new Random().Next(1, 4) %></div>
                                    <% } %>
                                </div>
                                <div class="item-card-content">
                                    <div class="item-name"><%# Eval("ItemName") %></div>
                                    <div class="item-price"><%# Eval("Price", "¥{0:N2}") %></div>
                                    <div class="item-meta">
                                        <div class="item-wear"><%# GetWearDesc(Eval("Rarity").ToString()) %></div>
                                        <div class="item-stock">库存: <%# Eval("Stock") %></div>
                                    </div>
                                    <div class="item-actions">
                                        <asp:Button ID="btnBuyNew" runat="server" CommandArgument='<%# Eval("ItemId") %>' Text="立即购买" CssClass="btn-buy" OnClick="DirectBuy_Click" />
                                        <asp:Button ID="btnCartNew" runat="server" CommandArgument='<%# Eval("ItemId") %>' Text="加入购物车" CssClass="btn-cart" OnClick="AddToCart_Click" />
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <div class="pagination">
                    <asp:Repeater ID="rptNewPagination" runat="server">
                        <ItemTemplate><a href='<%# Eval("Url") %>' class='page-btn <%# Eval("CssClass") %>'><%# Eval("Text") %></a></ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <!-- 最新求购板块 -->
            <div class="section">
                <div class="section-header">
                    <div class="section-title"><i>📢</i> 最新求购</div>
                    <a href="BuyOrders.aspx" class="section-more">更多 ></a>
                </div>
                <div class="item-grid">
                    <asp:Repeater ID="rptBuyOrders" runat="server">
                        <ItemTemplate>
                            <div class="item-card" data-orderid='<%# Eval("OrderId") %>'>
                                <div class="item-img-container">
                                    <img class="item-img" src='<%# string.IsNullOrEmpty(Eval("ImageUrl")?.ToString()) || !Eval("ImageUrl").ToString().StartsWith("/img/") ? "/img/items/default.png" : Eval("ImageUrl") %>' alt='<%# Eval("ItemName") %>' onerror="this.src='/img/items/default.png'">
                                    <div class="wear-tag">求购</div>
                                </div>
                                <div class="item-card-content">
                                    <div class="item-name"><%# Eval("ItemName") %></div>
                                    <div class="item-price"><%# Eval("Price", "¥{0:N2}") %></div>
                                    <div class="item-meta">
                                        <div class="item-wear">求购数量: <%# Eval("Quantity") %></div>
                                        <div class="item-stock">状态: 有效</div>
                                    </div>
                                    <div class="item-actions">
                                        <asp:Button ID="btnSellOrder" runat="server" CommandArgument='<%# Eval("OrderId") %>' Text="立即出售" CssClass="btn-buy" OnClick="SellToBuyOrder_Click" />
                                        <button class="btn-cart" disabled>不可加购</button>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <div class="pagination">
                    <asp:Repeater ID="rptBuyPagination" runat="server">
                        <ItemTemplate><a href='<%# Eval("Url") %>' class='page-btn <%# Eval("CssClass") %>'><%# Eval("Text") %></a></ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
    </div>

  

    <script src="Scripts/jquery.js"></script>
    <script>
        // 打开/关闭购物车（纯后端回发）
        //$('#cartIcon').click(function () {
        //    __doPostBack('ToggleCart', '');
        //});
        //$('#overlay').click(function () {
        //    __doPostBack('ToggleCart', '');
        //});
    </script>
</asp:Content>