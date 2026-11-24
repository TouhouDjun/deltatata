<%@ Page Title="饰品市场 - 塔科夫交易行" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Marketplace.aspx.cs" Inherits="DeltaTradeHub.Marketplace" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .marketplace-container {
            max-width: 1400px;
            margin: 24px auto;
            padding: 0 20px;
            display: flex;
            gap: 24px;
        }
        .filter-sidebar {
            width: 260px;
            background: white;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            height: fit-content;
        }
        .filter-group {
            margin-bottom: 24px;
            border-bottom: 1px solid #edf2f7;
            padding-bottom: 16px;
        }
        .filter-group:last-child { border-bottom: none; }
        .filter-title {
            font-size: 15px;
            font-weight: 600;
            margin-bottom: 12px;
            color: #1e293b;
        }
        .filter-options {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }
        .filter-option {
            padding: 4px 12px;
            background: #f1f5f9;
            border-radius: 20px;
            font-size: 12px;
            cursor: pointer;
            transition: 0.2s;
        }
        .filter-option:hover, .filter-option.active {
            background: #ff7e00;
            color: white;
        }
        .marketplace-content {
            flex: 1;
        }
        .action-bar {
            background: white;
            border-radius: 16px;
            padding: 12px 20px;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
        }
        .search-box {
            display: flex;
            gap: 8px;
            flex: 1;
            max-width: 400px;
        }
        .search-box input {
            flex: 1;
            padding: 8px 14px;
            border: 1px solid #e2e8f0;
            border-radius: 40px;
            font-size: 14px;
        }
        .search-box button {
            background: #ff7e00;
            border: none;
            border-radius: 40px;
            padding: 0 20px;
            color: white;
            font-weight: 600;
            cursor: pointer;
        }
        .sort-select {
            padding: 8px 14px;
            border: 1px solid #e2e8f0;
            border-radius: 40px;
            background: white;
            font-size: 14px;
        }
        .items-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .item-card {
            background: white;
            border-radius: 16px;
            overflow: hidden;
            transition: all 0.2s;
            border: 1px solid #edf2f7;
            cursor: pointer;
        }
        .item-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.08);
            border-color: #ffd9b3;
        }
        .item-img {
            width: 100%;
            aspect-ratio: 1 / 1;
            object-fit: contain;
            background: #f8fafc;
            padding: 12px;
        }
        .item-info {
            padding: 12px;
        }
        .item-name {
            font-weight: 600;
            font-size: 14px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            margin-bottom: 4px;
        }
        .item-price {
            font-weight: 700;
            color: #ff7e00;
            font-size: 16px;
            margin-bottom: 4px;
        }
        .item-meta {
            display: flex;
            justify-content: space-between;
            font-size: 11px;
            color: #94a3b8;
        }
        .btn-buy, .btn-cart {
            border: none;
            border-radius: 40px;
            padding: 5px 0;
            font-size: 12px;
            font-weight: 600;
            margin-top: 8px;
            width: 100%;
            cursor: pointer;
        }
        .btn-buy {
            background: #ff7e00;
            color: white;
        }
        .btn-cart {
            background: #f1f5f9;
            color: #1e293b;
            margin-top: 4px;
        }
        .pagination {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-top: 20px;
        }
        .pagination a, .pagination span {
            display: inline-block;
            padding: 6px 12px;
            background: white;
            border-radius: 30px;
            color: #64748b;
            text-decoration: none;
            font-size: 14px;
            border: 1px solid #e2e8f0;
        }
        .pagination a:hover {
            background: #ff7e00;
            color: white;
            border-color: #ff7e00;
        }
        .pagination .current-page {
            background: #ff7e00;
            color: white;
            border-color: #ff7e00;
        }
    </style>

    <div class="marketplace-container">
        <!-- 左侧筛选项 -->
        <div class="filter-sidebar">
            <div class="filter-group">
                <div class="filter-title">🔥 热门游戏</div>
                <div class="filter-options">
                    <asp:Repeater ID="rptCategories" runat="server">
                        <ItemTemplate>
                            <div class="filter-option" data-catid='<%# Eval("CategoryId") %>'><%# Eval("CategoryName") %></div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
            <div class="filter-group">
                <div class="filter-title">⭐ 品质</div>
                <div class="filter-options">
                    <div class="filter-option" data-quality="factory_new">崭新出厂</div>
                    <div class="filter-option" data-quality="minimal_wear">略有磨损</div>
                    <div class="filter-option" data-quality="field_tested">久经沙场</div>
                    <div class="filter-option" data-quality="well_worn">破损不堪</div>
                    <div class="filter-option" data-quality="battle_scarred">战痕累累</div>
                </div>
            </div>
        </div>

        <!-- 右侧内容 -->
        <div class="marketplace-content">
            <div class="action-bar">
                <div class="search-box">
                    <asp:TextBox ID="txtKeyword" runat="server" placeholder="输入物品名称" CssClass="form-control" />
                    <asp:Button ID="btnSearch" runat="server" Text="Q 搜索" OnClick="btnSearch_Click" />
                </div>
                <asp:DropDownList ID="ddlSort" runat="server" CssClass="sort-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
                    <asp:ListItem Value="price_asc" Text="价格 低→高" />
                    <asp:ListItem Value="price_desc" Text="价格 高→低" />
                    <asp:ListItem Value="time_desc" Text="最新上架" />
                </asp:DropDownList>
            </div>

            <div class="items-grid">
                <asp:Repeater ID="rptItems" runat="server">
                    <ItemTemplate>
                        <div class="item-card" data-id='<%# Eval("ItemId") %>'>
                            <img class="item-img" src='<%# Eval("ImageUrl") %>' onerror="this.src='/img/items/default.png'" />
                            <div class="item-info">
                                <div class="item-name"><%# Eval("ItemName") %></div>
                                <div class="item-price">¥<%# Eval("Price", "{0:N2}") %></div>
                                <div class="item-meta">
                                    <span><%# GetWearText(Eval("Rarity").ToString()) %></span>
                                    <span>库存: <%# Eval("Stock") %></span>
                                </div>
                                <button class="btn-buy buy-now" data-id='<%# Eval("ItemId") %>'>立即购买</button>
                                <button class="btn-cart add-cart" data-id='<%# Eval("ItemId") %>'>加入购物车</button>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
            <asp:Literal ID="litNoData" runat="server" Visible="false" Text='<div style="text-align:center; padding:40px; color:#999;">暂无相关饰品</div>' />

            <div class="pagination">
                <asp:Repeater ID="rptPagination" runat="server">
                    <ItemTemplate>
                        <a href='<%# Eval("Url") %>' class='<%# Eval("CssClass") %>'><%# Eval("Text") %></a>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

    <script src="Scripts/jquery.js"></script>
    <script>
        // 分类筛选 (通过 URL 参数)
        $('.filter-option[data-catid]').click(function () {
            var catId = $(this).data('catid');
            window.location.href = 'Marketplace.aspx?cat=' + catId;
        });
        // 品质筛选
        $('.filter-option[data-quality]').click(function () {
            var quality = $(this).data('quality');
            window.location.href = 'Marketplace.aspx?quality=' + quality;
        });
        // 高亮当前激活的筛选项
        var urlParams = new URLSearchParams(window.location.search);
        var activeCat = urlParams.get('cat');
        var activeQuality = urlParams.get('quality');
        if (activeCat) $('.filter-option[data-catid="' + activeCat + '"]').addClass('active');
        if (activeQuality) $('.filter-option[data-quality="' + activeQuality + '"]').addClass('active');

        // 购买和加购（使用 PostBack 避免 401）
        $('.buy-now').click(function () {
            var itemId = $(this).data('id');
            if (confirm('确认购买该饰品吗？')) {
                __doPostBack('Buy', itemId);
            }
        });
        $('.add-cart').click(function () {
            var itemId = $(this).data('id');
            __doPostBack('Cart', itemId);
        });
        $(document).on('click', '.item-card', function (e) {
            if ($(e.target).is('button')) return;
            var itemId = $(this).data('id');
            if (itemId) {
                window.location.href = 'ItemDetail.aspx?id=' + itemId;
            }
        });
    </script>
</asp:Content>