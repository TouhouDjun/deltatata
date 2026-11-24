<%@ Page Title="求购市场 - 塔科夫交易行" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BuyOrders.aspx.cs" Inherits="DeltaTradeHub.BuyOrders" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .buy-container {
            max-width: 1200px;
            margin: 24px auto;
            padding: 0 20px;
        }
        .action-bar {
            background: white;
            border-radius: 16px;
            padding: 16px 20px;
            margin-bottom: 24px;
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
            max-width: 350px;
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
        .btn-primary {
            background: #ff7e00;
            border: none;
            border-radius: 40px;
            padding: 8px 24px;
            color: white;
            font-weight: 600;
            cursor: pointer;
        }
        .btn-outline {
            background: #f1f5f9;
            border: 1px solid #e2e8f0;
            border-radius: 40px;
            padding: 6px 16px;
            cursor: pointer;
            font-size: 13px;
        }
        .orders-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 20px;
        }
        .order-card {
            background: white;
            border-radius: 16px;
            padding: 16px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            border: 1px solid #edf2f7;
            transition: 0.2s;
        }
        .order-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.08);
            border-color: #ffd9b3;
        }
        .order-item-name {
            font-size: 16px;
            font-weight: 700;
            margin-bottom: 8px;
            color: #1e293b;
        }
        .order-meta {
            display: flex;
            justify-content: space-between;
            font-size: 13px;
            color: #64748b;
            margin-bottom: 12px;
        }
        .order-price {
            font-size: 20px;
            font-weight: 700;
            color: #ff7e00;
            margin: 8px 0;
        }
        .order-quantity {
            font-size: 13px;
            margin-bottom: 12px;
        }
        .order-actions {
            display: flex;
            gap: 8px;
            margin-top: 12px;
        }
        .btn-sell, .btn-cancel {
            flex: 1;
            border: none;
            border-radius: 30px;
            padding: 8px 0;
            font-weight: 600;
            cursor: pointer;
        }
        .btn-sell {
            background: #ff7e00;
            color: white;
        }
        .btn-cancel {
            background: #f1f5f9;
            color: #dc3545;
        }
        .empty-msg {
            text-align: center;
            padding: 60px;
            color: #94a3b8;
        }
        .pagination {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-top: 30px;
        }
        .page-btn {
            padding: 6px 12px;
            border-radius: 30px;
            background: #f1f5f9;
            color: #64748b;
            text-decoration: none;
        }
        .page-btn.active {
            background: #ff7e00;
            color: white;
        }
        /* 模态框 */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 1050;
            justify-content: center;
            align-items: center;
        }
        .modal-content {
            background: white;
            border-radius: 24px;
            width: 500px;
            max-width: 90%;
            padding: 24px;
        }
        .modal-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 16px;
            font-weight: 700;
            font-size: 18px;
        }
        .modal-body input, .modal-body select {
            width: 100%;
            padding: 10px;
            margin-bottom: 16px;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
        }
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 16px;
        }
        .close {
            cursor: pointer;
            font-size: 24px;
        }
    </style>

    <div class="buy-container">
        <div class="action-bar">
            <div class="search-box">
                <asp:TextBox ID="txtSearch" runat="server" placeholder="搜索物品名称..." CssClass="form-control" />
                <asp:Button ID="btnSearch" runat="server" Text="Q 搜索" OnClick="btnSearch_Click" />
            </div>
            <button type="button" class="btn-primary" id="btnShowPublish">+ 发布求购</button>
            <asp:CheckBox ID="chkOnlyMine" runat="server" Text="只看我的求购" AutoPostBack="true" OnCheckedChanged="chkOnlyMine_CheckedChanged" />
        </div>

        <div class="orders-grid">
            <asp:Repeater ID="rptBuyOrders" runat="server" OnItemCommand="rptBuyOrders_ItemCommand">
                <ItemTemplate>
                    <div class="order-card">
                        <div class="order-item-name"><%# Eval("ItemName") %></div>
                        <div class="order-meta">
                            <span>发布者：<%# Eval("PublisherName") %></span>
                            <span><%# Eval("CreateDate", "{0:yyyy-MM-dd}") %></span>
                        </div>
                        <div class="order-price">¥<%# Eval("Price", "{0:N2}") %></div>
                        <div class="order-quantity">求购数量：<%# Eval("Quantity") %></div>
                        <div class="order-actions">
                            <asp:Button ID="btnSell" runat="server" CommandName="Sell" CommandArgument='<%# Eval("OrderId") %>' Text="出售" CssClass="btn-sell" Visible='<%# (int)Eval("UserId") != GetCurrentUserId() %>' />
                            <asp:Button ID="btnCancel" runat="server" CommandName="Cancel" CommandArgument='<%# Eval("OrderId") %>' Text="取消求购" CssClass="btn-cancel" Visible='<%# (int)Eval("UserId") == GetCurrentUserId() %>' />
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <asp:Literal ID="litNoData" runat="server" Visible="false" Text='<div class="empty-msg">暂无求购信息</div>' />

        <div id="paginationDiv" class="pagination" runat="server">
            <asp:Repeater ID="rptPagination" runat="server">
                <ItemTemplate>
                    <a href='<%# Eval("Url") %>' class='page-btn <%# Eval("CssClass") %>'><%# Eval("Text") %></a>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>

    <!-- 发布求购模态框 -->
    <div id="publishModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span>发布求购</span>
                <span class="close" id="closeModal">&times;</span>
            </div>
            <div class="modal-body">
                <asp:DropDownList ID="ddlItem" runat="server" CssClass="form-control">
                    <asp:ListItem Text="请选择物品" Value="" />
                </asp:DropDownList>
                <asp:TextBox ID="txtQuantity" runat="server" placeholder="求购数量" TextMode="Number" CssClass="form-control" />
                <asp:TextBox ID="txtPrice" runat="server" placeholder="单价 (币)" TextMode="Number" step="0.01" CssClass="form-control" />
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-outline" id="btnCancelModal">取消</button>
                <asp:Button ID="btnPublish" runat="server" Text="发布" CssClass="btn-primary" OnClick="btnPublish_Click" />
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
    <script>
        $(function () {
            var modal = $('#publishModal');
            $('#btnShowPublish').click(function () {
                modal.css('display', 'flex');
            });
            $('#closeModal, #btnCancelModal').click(function () {
                modal.css('display', 'none');
            });
            $(window).click(function (e) {
                if (e.target == modal[0]) modal.css('display', 'none');
            });
        });
    </script>
</asp:Content>