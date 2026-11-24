<%@ Page Title="我的库存 - 塔科夫交易行" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Storehouse.aspx.cs" Inherits="DeltaTradeHub.Storehouse" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .storehouse-container {
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
        .inventory-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .inventory-card {
            background: white;
            border-radius: 16px;
            overflow: hidden;
            transition: 0.2s;
            border: 1px solid #edf2f7;
            display: flex;
            flex-direction: column;
        }
        .inventory-card:hover {
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
        .item-quantity {
            font-size: 14px;
            font-weight: 500;
            color: #ff7e00;
            margin-bottom: 8px;
        }
        .item-acquire {
            font-size: 11px;
            color: #94a3b8;
            margin-bottom: 12px;
        }
        .card-actions {
            display: flex;
            gap: 8px;
            margin-top: 8px;
        }
        .btn-sell, .btn-use {
            flex: 1;
            border: none;
            border-radius: 30px;
            padding: 6px 0;
            font-weight: 600;
            cursor: pointer;
        }
        .btn-sell {
            background: #ff7e00;
            color: white;
        }
        .btn-use {
            background: #f1f5f9;
            color: #1e293b;
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

    <div class="storehouse-container">
        <div class="page-header">
            <div class="page-title">📦 我的库存</div>
            <div class="search-box">
                <asp:TextBox ID="txtSearch" runat="server" placeholder="搜索物品名称" CssClass="form-control" />
                <asp:Button ID="btnSearch" runat="server" Text="搜索" OnClick="btnSearch_Click" />
            </div>
        </div>

        <div class="inventory-grid">
            <asp:Repeater ID="rptInventory" runat="server" OnItemCommand="rptInventory_ItemCommand">
                <ItemTemplate>
                    <div class="inventory-card">
                        <img class="card-img" src='<%# Eval("ImageUrl") %>' onerror="this.src='/img/items/default.png'" />
                        <div class="card-info">
                            <div class="item-name"><%# Eval("ItemName") %></div>
                            <div class="item-meta">
                                <span><%# Eval("RarityText") %></span>
                                <span>单价: ¥<%# Eval("Price", "{0:N2}") %></span>
                            </div>
                            <div class="item-quantity">数量: x<%# Eval("Quantity") %></div>
                            <div class="item-acquire">获得时间: <%# Eval("AcquireDate", "{0:yyyy-MM-dd}") %></div>
                            <div class="card-actions">
                                <asp:Button ID="btnSell" runat="server" CommandName="Sell" CommandArgument='<%# Eval("InventoryId") %>' Text="出售" CssClass="btn-sell" />
                                <asp:Button ID="btnUse" runat="server" CommandName="Use" CommandArgument='<%# Eval("InventoryId") %>' Text="使用" CssClass="btn-use" Visible='<%# (bool)Eval("IsUsable") %>' />
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <asp:Literal ID="litNoData" runat="server" Visible="false" Text='<div class="empty-msg">暂无库存，快去市场购买吧！</div>' />

        <div class="pagination" id="paginationDiv" runat="server">
            <asp:Repeater ID="rptPagination" runat="server">
                <ItemTemplate>
                    <a href='<%# Eval("Url") %>' class='page-btn <%# Eval("CssClass") %>'><%# Eval("Text") %></a>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>

    <!-- 出售模态框 -->
    <div id="sellModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span>上架出售</span>
                <span class="close" id="closeModal">&times;</span>
            </div>
            <div class="modal-body">
                <label>价格 (币)</label>
                <input type="number" id="sellPrice" step="0.01" placeholder="请输入售价" />
                <label>数量</label>
                <input type="number" id="sellQuantity" min="1" placeholder="请输入数量" />
                <input type="hidden" id="sellInventoryId" />
            </div>
            <div class="modal-footer">
                <button class="btn-outline" id="cancelModal">取消</button>
                <button class="btn-primary" id="confirmSell">确认上架</button>
            </div>
        </div>
    </div>

    <script src="Scripts/jquery-3.7.0.min.js"></script>
    <script>
        var modal = $('#sellModal');
        var currentInventoryId = null;

        $('.btn-sell').click(function(e) {
            e.preventDefault();
            currentInventoryId = $(this).data('id') || $(this).closest('.inventory-card').find('.btn-sell').attr('data-id');
            // 获取当前卡片上的最大数量（从item-quantity提取）
            var qtyText = $(this).closest('.inventory-card').find('.item-quantity').text();
            var maxQty = parseInt(qtyText.match(/\d+/)[0]);
            $('#sellQuantity').attr('max', maxQty).val(1);
            $('#sellPrice').val('');
            $('#sellInventoryId').val(currentInventoryId);
            modal.css('display', 'flex');
        });

        $('#closeModal, #cancelModal').click(function() {
            modal.css('display', 'none');
        });

        $('#confirmSell').click(function() {
            var inventoryId = $('#sellInventoryId').val();
            var price = parseFloat($('#sellPrice').val());
            var quantity = parseInt($('#sellQuantity').val());
            if (isNaN(price) || price <= 0 || isNaN(quantity) || quantity <= 0) {
                alert('请填写有效的价格和数量');
                return;
            }
            // 触发服务器端事件
            __doPostBack('SellItem', inventoryId + '|' + price + '|' + quantity);
        });

        window.onclick = function(event) {
            if (event.target == modal[0]) modal.css('display', 'none');
        }
    </script>
</asp:Content>