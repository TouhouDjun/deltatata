<%@ Page Title="饰品详情 - 塔科夫交易行" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ItemDetail.aspx.cs" Inherits="DeltaTradeHub.ItemDetail" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .detail-container {
            max-width: 1200px;
            margin: 24px auto;
            padding: 0 20px;
        }
        .breadcrumb-custom {
            margin-bottom: 20px;
            font-size: 13px;
            color: #64748b;
        }
        .item-main {
            background: white;
            border-radius: 16px;
            padding: 24px;
            display: flex;
            gap: 32px;
            margin-bottom: 32px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        .item-img-area {
            width: 300px;
            flex-shrink: 0;
        }
        .item-img {
            width: 100%;
            border-radius: 12px;
            background: #f8fafc;
        }
        .item-info-area {
            flex: 1;
        }
        .item-title {
            font-size: 22px;
            font-weight: 700;
            margin-bottom: 8px;
        }
        .item-sub {
            display: flex;
            gap: 16px;
            font-size: 13px;
            color: #64748b;
            margin-bottom: 16px;
        }
        .item-price-range {
            background: #f8fafc;
            padding: 16px;
            border-radius: 12px;
            margin: 16px 0;
        }
        .price-row {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            margin-top: 12px;
        }
        .price-item {
            background: white;
            padding: 8px 12px;
            border-radius: 8px;
            min-width: 100px;
            text-align: center;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
        }
        .price-wear {
            font-size: 12px;
            color: #64748b;
        }
        .price-value {
            font-size: 18px;
            font-weight: 700;
            color: #ff7e00;
        }
        .action-buttons {
            display: flex;
            gap: 16px;
            margin-top: 20px;
        }
        .btn-sell, .btn-buy-now {
            padding: 10px 24px;
            border-radius: 40px;
            font-weight: 600;
            border: none;
            cursor: pointer;
        }
        .btn-sell {
            background: #f1f5f9;
            color: #1e293b;
        }
        .btn-buy-now {
            background: #ff7e00;
            color: white;
        }
        .listing-section {
            background: white;
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 32px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        .section-title {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .listing-table {
            width: 100%;
            border-collapse: collapse;
        }
        .listing-table th, .listing-table td {
            padding: 12px 8px;
            text-align: left;
            border-bottom: 1px solid #edf2f7;
        }
        .listing-table th {
            font-weight: 600;
            color: #64748b;
            font-size: 13px;
        }
        .seller-name {
            font-weight: 500;
        }
        .listing-price {
            color: #ff7e00;
            font-weight: 700;
        }
        .btn-small-buy {
            background: #ff7e00;
            color: white;
            border: none;
            border-radius: 20px;
            padding: 4px 12px;
            font-size: 12px;
            cursor: pointer;
        }
        .pagination {
            margin-top: 20px;
            display: flex;
            justify-content: center;
            gap: 8px;
        }
        .page-btn {
            padding: 4px 10px;
            border-radius: 20px;
            background: #f1f5f9;
            color: #64748b;
            text-decoration: none;
        }
        .page-btn.active {
            background: #ff7e00;
            color: white;
        }
        .sort-select {
            padding: 4px 8px;
            border-radius: 20px;
            border: 1px solid #e2e8f0;
            background: white;
        }
    </style>

    <div class="detail-container">
        <div class="breadcrumb-custom">
            <a href="Marketplace.aspx">饰品市场</a> &gt; 
            <asp:Literal ID="litItemName" runat="server"></asp:Literal>
        </div>

        <div class="item-main">
            <div class="item-img-area">
                <img class="item-img" id="imgItem" runat="server" />
            </div>
            <div class="item-info-area">
                <div class="item-title"><asp:Literal ID="litFullName" runat="server"></asp:Literal></div>
                <div class="item-sub">
                    <span>品质：<asp:Literal ID="litRarity" runat="server"></asp:Literal></span>
                    <span>类别：<asp:Literal ID="litCategory" runat="server"></asp:Literal></span>
                </div>
                <div class="item-price-range">
                    <div>参考价格区间</div>
                    <div class="price-row" id="priceRangePanel" runat="server">
                        <!-- 动态生成 -->
                    </div>
                </div>
                <div class="action-buttons">
                    <asp:Button ID="btnSell" runat="server" Text="我要出售" CssClass="btn-sell" OnClick="btnSell_Click" />
                    <asp:Button ID="btnBuyNow" runat="server" Text="我要求购" CssClass="btn-buy-now" OnClick="btnBuyNow_Click" />
                </div>
            </div>
        </div>

        <div class="listing-section">
            <div class="section-title">
                <span>当前在售（<asp:Literal ID="litListingCount" runat="server"></asp:Literal>）</span>
                <span>排序：<asp:DropDownList ID="ddlSort" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged" CssClass="sort-select">
                        <asp:ListItem Value="price_asc" Text="价格 低→高" />
                        <asp:ListItem Value="price_desc" Text="价格 高→低" />
                    </asp:DropDownList>
                </span>
            </div>
            <asp:Repeater ID="rptListings" runat="server" OnItemCommand="rptListings_ItemCommand">
                <HeaderTemplate>
                    <table class="listing-table">
                        <thead>
                            <tr><th>磨损度</th><th>磨损值</th><th>卖家</th><th>价格</th><th>操作</th></tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("Wear") %></td>
                        <td><%# Eval("WearValue") %></td>
                        <td class="seller-name"><%# Eval("SellerName") %></td>
                        <td class="listing-price">¥<%# Eval("Price", "{0:N2}") %></td>
                        <td><asp:Button ID="btnBuy" runat="server" CommandName="Buy" CommandArgument='<%# Eval("ListingId") %>' Text="购买" CssClass="btn-small-buy" /></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
            <asp:Literal ID="litNoListings" runat="server" Visible="false" Text='<div style="text-align:center; padding:30px;">暂无在售饰品</div>' />
            <div class="pagination" id="paginationDiv" runat="server">
                <asp:Repeater ID="rptPagination" runat="server">
                    <ItemTemplate><a href='<%# Eval("Url") %>' class='page-btn <%# Eval("CssClass") %>'><%# Eval("Text") %></a></ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>
</asp:Content>