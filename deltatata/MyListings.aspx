<%@ Page Title="我的出售 - 塔科夫交易行" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MyListings.aspx.cs" Inherits="DeltaTradeHub.MyListings" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .listings-container {
            max-width: 1200px;
            margin: 24px auto;
            padding: 0 20px;
        }
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }
        .page-title {
            font-size: 24px;
            font-weight: 700;
            color: #1e293b;
        }
        .search-box {
            display: flex;
            gap: 8px;
        }
        .search-box input {
            padding: 8px 14px;
            border: 1px solid #e2e8f0;
            border-radius: 40px;
            width: 240px;
        }
        .search-box button {
            background: #ff7e00;
            border: none;
            border-radius: 40px;
            padding: 0 20px;
            color: white;
            cursor: pointer;
        }
        .listings-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .listing-card {
            background: white;
            border-radius: 16px;
            overflow: hidden;
            transition: 0.2s;
            border: 1px solid #edf2f7;
            display: flex;
            flex-direction: column;
        }
        .listing-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.08);
            border-color: #ffd9b3;
        }
        .card-img {
            width: 100%;
            aspect-ratio: 1 / 1;
            object-fit: contain;
            background: #f8fafc;
            padding: 16px;
        }
        .card-info {
            padding: 16px;
            flex: 1;
        }
        .item-name {
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 4px;
        }
        .item-meta {
            font-size: 12px;
            color: #64748b;
            margin-bottom: 8px;
            display: flex;
            justify-content: space-between;
        }
        .listing-price {
            font-size: 18px;
            font-weight: 700;
            color: #ff7e00;
            margin-bottom: 8px;
        }
        .listing-quantity {
            font-size: 14px;
            color: #334155;
            margin-bottom: 12px;
        }
        .listing-status {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            margin-bottom: 12px;
        }
        .status-active {
            background: #dcfce7;
            color: #15803d;
        }
        .status-sold {
            background: #fee2e2;
            color: #b91c1c;
        }
        .card-actions {
            display: flex;
            gap: 8px;
            margin-top: 8px;
        }
        .btn-edit, .btn-cancel {
            flex: 1;
            border: none;
            border-radius: 30px;
            padding: 6px 0;
            font-weight: 600;
            cursor: pointer;
        }
        .btn-edit {
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
            margin-top: 20px;
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
            width: 400px;
            padding: 24px;
        }
        .modal-header {
            display: flex;
            justify-content: space-between;
            font-weight: 700;
            font-size: 18px;
            margin-bottom: 16px;
        }
        .modal-body input {
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
        }
    </style>

    <div class="listings-container">
        <div class="page-header">
            <div class="page-title">📤 我的出售</div>
            <div class="search-box">
                <asp:TextBox ID="txtSearch" runat="server" placeholder="搜索物品名称" CssClass="form-control" />
                <asp:Button ID="btnSearch" runat="server" Text="搜索" OnClick="btnSearch_Click" />
            </div>
        </div>

        <div class="listings-grid">
            <asp:Repeater ID="rptListings" runat="server" OnItemCommand="rptListings_ItemCommand">
                <ItemTemplate>
                    <div class="listing-card">
                        <img class="card-img" src='<%# Eval("ImageUrl") %>' onerror="this.src='/img/items/default.png'" />
                        <div class="card-info">
                            <div class="item-name"><%# Eval("ItemName") %></div>
                            <div class="item-meta">
                                <span><%# Eval("RarityText") %></span>
                                <span>上架时间: <%# Eval("CreateDate", "{0:yyyy-MM-dd}") %></span>
                            </div>
                            <div class="listing-price">¥<%# Eval("Price", "{0:N2}") %></div>
                            <div class="listing-quantity">数量: <%# Eval("Quantity") %></div>
                            <div class="listing-status status-<%# Eval("StatusClass") %>"><%# Eval("StatusText") %></div>
                            <div class="card-actions">
                                <asp:Button ID="btnEdit" runat="server" CommandName="Edit" CommandArgument='<%# Eval("ListingId") %>' Text="修改价格" CssClass="btn-edit" Visible='<%# Eval("IsActive") %>' />
                                <asp:Button ID="btnCancel" runat="server" CommandName="Cancel" CommandArgument='<%# Eval("ListingId") %>' Text="下架" CssClass="btn-cancel" Visible='<%# Eval("IsActive") %>' />
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <asp:Literal ID="litNoData" runat="server" Visible="false" Text='<div class="empty-msg">暂无挂售商品，快去上架吧！</div>' />

        <div class="pagination" id="paginationDiv" runat="server">
            <asp:Repeater ID="rptPagination" runat="server">
                <ItemTemplate>
                    <a href='<%# Eval("Url") %>' class='page-btn <%# Eval("CssClass") %>'><%# Eval("Text") %></a>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>

    <!-- 修改价格模态框 -->
    <div id="priceModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span>修改价格</span>
                <span class="close" id="closeModal">&times;</span>
            </div>
            <div class="modal-body">
                <label>新价格 (币)</label>
                <input type="number" id="newPrice" step="0.01" placeholder="请输入新价格" />
                <input type="hidden" id="editListingId" />
            </div>
            <div class="modal-footer">
                <button class="btn-outline" id="cancelModal">取消</button>
                <button class="btn-primary" id="confirmEdit">确认修改</button>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
    <script>
        var modal = $('#priceModal');
        var currentListingId = null;

        $('.btn-edit').click(function(e) {
            e.preventDefault();
            currentListingId = $(this).closest('.listing-card').find('.btn-edit').attr('commandargument');
            $('#editListingId').val(currentListingId);
            var currentPrice = $(this).closest('.listing-card').find('.listing-price').text().replace('¥', '');
            $('#newPrice').val(parseFloat(currentPrice));
            modal.css('display', 'flex');
        });

        $('#closeModal, #cancelModal').click(function() {
            modal.css('display', 'none');
        });

        $('#confirmEdit').click(function() {
            var listingId = $('#editListingId').val();
            var newPrice = parseFloat($('#newPrice').val());
            if (isNaN(newPrice) || newPrice <= 0) {
                alert('请输入有效的价格');
                return;
            }
            __doPostBack('UpdatePrice', listingId + '|' + newPrice);
        });

        window.onclick = function(event) {
            if (event.target == modal[0]) modal.css('display', 'none');
        }
    </script>
</asp:Content>