<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HotItems.aspx.cs" Inherits="DeltaTradeHub.HotItems" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>热门饰品 - ATRADE交易平台</title>
    <style>
        /* 全局样式重置 */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: "Microsoft YaHei", sans-serif; }
        body { background-color: #f5f5f7; }
        .top-nav { background-color: #1a1a2e; height: 60px; display: flex; align-items: center; padding: 0 20px; position: sticky; top: 0; z-index: 999; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .nav-logo { color: #fff; font-size: 24px; font-weight: bold; margin-right: 40px; text-decoration: none; }
        .nav-menu { display: flex; gap: 25px; }
        .nav-menu a { color: #fff; text-decoration: none; font-size: 16px; transition: color 0.2s ease; }
        .nav-menu a:hover { color: #ff8a00; }
        .nav-right { margin-left: auto; display: flex; align-items: center; gap: 20px; color: #fff; }
        .nav-right .balance { color: #ffd700; font-weight: bold; }
        .back-btn { background-color: #ff8a00; color: #fff; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; font-size: 14px; margin-right: 10px; transition: background-color 0.2s ease; }
        .back-btn:hover { background-color: #e07a00; }
        .container { max-width: 1200px; margin: 20px auto; padding: 0 20px; }
        .page-header { display: flex; align-items: center; margin-bottom: 30px; padding-bottom: 15px; border-bottom: 1px solid #eee; }
        .page-title { font-size: 28px; color: #333; margin: 0; }
        .item-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 40px; }
        .item-card { background-color: #fff; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.1); transition: all 0.3s ease; padding: 15px; }
        .item-card:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
        .item-img { width: 100%; height: 180px; object-fit: cover; border-radius: 4px; margin-bottom: 12px; background-color: #f0f0f0; }
        .item-name { font-size: 16px; color: #333; margin-bottom: 8px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; font-weight: 500; }
        .item-price { font-size: 18px; color: #ff8a00; font-weight: bold; margin-bottom: 8px; }
        .item-rarity { font-size: 12px; color: #666; margin-bottom: 8px; }
        .item-stock { font-size: 12px; color: #999; margin-bottom: 15px; }
        .btn-group { display: flex; gap: 8px; }
        .btn-buy, .btn-cart { flex: 1; padding: 8px 0; border: none; border-radius: 4px; font-size: 14px; cursor: pointer; transition: all 0.2s ease; }
        .btn-buy { background-color: #ff8a00; color: white; }
        .btn-buy:hover { background-color: #e07a00; }
        .btn-buy:disabled { background-color: #ccc; cursor: not-allowed; }
        .btn-cart { background-color: #f0f0f0; color: #666; border: 1px solid #ddd; }
        .btn-cart:hover { background-color: #e8e8e8; }
        .btn-cart:disabled { background-color: #f5f5f5; color: #999; cursor: not-allowed; }
        .pagination { display: flex; justify-content: center; align-items: center; gap: 8px; margin-top: 20px; }
        .pagination a { display: inline-block; padding: 8px 16px; border: 1px solid #eee; border-radius: 4px; color: #333; text-decoration: none; background-color: #fff; transition: all 0.2s ease; }
        .pagination a.active { background-color: #ff8a00; color: white; border-color: #ff8a00; }
        .pagination a:hover:not(.active) { border-color: #ff8a00; color: #ff8a00; }
        .no-data { text-align: center; font-size: 18px; color: #999; padding: 50px 0; background-color: #fff; border-radius: 8px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="top-nav">
        <a href="Market.aspx" class="nav-logo">ATRACE</a>
        <div class="nav-menu">
            <a href="Market.aspx">首页</a>
            <a href="HotItems.aspx" class="active">饰品市场</a>
            <a href="#">资讯</a>
            <a href="#">自定义检视</a>
            <a href="#">趋势榜单</a>
        </div>
        <div class="nav-right">
            <span>rushb</span>
            <span class="balance">资金¥2970.00</span>
        </div>
    </div>

    <form id="form1" runat="server">
        <div class="container">
            <div class="page-header">
                <a href="Market.aspx" class="back-btn" style="text-decoration: none;">← 返回首页</a>
                <h1 class="page-title">热门饰品</h1>
            </div>

            <asp:Literal ID="litNoData" runat="server" Visible="false" Text='<div class="no-data">暂无热门饰品数据</div>' />

            <asp:Repeater ID="rptHotItems" runat="server">
                <HeaderTemplate><div class="item-grid"></HeaderTemplate>
                <ItemTemplate>
                    <div class="item-card">
                        <img src='<%# Eval("ImageUrl") != DBNull.Value && !string.IsNullOrEmpty(Eval("ImageUrl").ToString()) && Eval("ImageUrl").ToString().StartsWith("/img/") ? Eval("ImageUrl") : "/img/items/default.png" %>' 
                             alt='<%# Eval("ItemName") %>' class="item-img" onerror="this.src='/img/items/default.png'" />
                        <div class="item-info">
                            <h3 class="item-name"><%# Eval("ItemName") %></h3>
                            <p class="item-price">¥<%# string.Format("{0:0.00}", Eval("Price")) %></p>
                            <p class="item-rarity">磨损度：<%# GetWearDesc(Eval("Rarity").ToString()) %></p>
                            <p class="item-stock">库存：<%# Eval("Stock") %>件</p>
                            <div class="btn-group">
                                <asp:Button ID="btnBuy" runat="server" 
                                    CommandArgument='<%# Eval("ItemId") %>' 
                                    Text='<%# Convert.ToInt32(Eval("Stock")) <= 0 ? "已售罄" : "立即购买" %>'
                                    CssClass="btn-buy"
                                    Enabled='<%# Convert.ToInt32(Eval("Stock")) > 0 %>'
                                    OnClick="BuyItem_Click" />
                                <asp:Button ID="btnCart" runat="server" 
                                    CommandArgument='<%# Eval("ItemId") %>' 
                                    Text="加入购物车"
                                    CssClass="btn-cart"
                                    Enabled='<%# Convert.ToInt32(Eval("Stock")) > 0 %>'
                                    OnClick="AddCart_Click" />
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate></div></FooterTemplate>
            </asp:Repeater>

            <asp:Repeater ID="rptPagination" runat="server">
                <HeaderTemplate><div class="pagination"></HeaderTemplate>
                <ItemTemplate><a href='<%# Eval("Url") %>' class='<%# Eval("CssClass") %>'><%# Eval("Text") %></a></ItemTemplate>
                <FooterTemplate></div></FooterTemplate>
            </asp:Repeater>
        </div>
    </form>
</body>
</html>