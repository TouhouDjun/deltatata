<%@ Page Title="商品管理" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="AdminItems.aspx.cs" Inherits="DeltaTradeHub.AdminItems" %>

<asp:Content ID="Content1" ContentPlaceHolderID="PageTitle" runat="server">
    商品管理
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .search-bar {
            background: white;
            border-radius: 16px;
            padding: 16px 20px;
            margin-bottom: 20px;
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            align-items: flex-end;
        }
        .search-item {
            flex: 1;
            min-width: 150px;
        }
        .search-item label {
            display: block;
            font-size: 12px;
            margin-bottom: 4px;
            color: #64748b;
        }
        .search-item select, .search-item input {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
        }
        .search-bar button {
            background: #ff7e00;
            border: none;
            border-radius: 30px;
            padding: 8px 24px;
            color: white;
            cursor: pointer;
            height: 42px;
        }
        .btn-add {
            background: #10b981;
            margin-left: auto;
        }
        .item-table {
            width: 100%;
            background: white;
            border-radius: 16px;
            overflow-x: auto;
            border: 1px solid #edf2f7;
        }
        .item-table th, .item-table td {
            padding: 12px 12px;
            text-align: left;
            border-bottom: 1px solid #edf2f7;
        }
        .item-table th {
            background: #f8fafc;
            font-weight: 600;
        }
        .item-img {
            width: 50px;
            height: 50px;
            object-fit: contain;
            background: #f8fafc;
            border-radius: 8px;
        }
        .status-badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 20px;
            font-size: 12px;
        }
        .status-on {
            background: #dcfce7;
            color: #15803d;
        }
        .status-off {
            background: #fee2e2;
            color: #b91c1c;
        }
        .btn-toggle, .btn-edit, .btn-delete {
            border: none;
            border-radius: 20px;
            padding: 4px 12px;
            margin: 2px;
            cursor: pointer;
        }
        .btn-toggle {
            background: #ff7e00;
            color: white;
        }
        .btn-edit {
            background: #3b82f6;
            color: white;
        }
        .btn-delete {
            background: #ef4444;
            color: white;
        }
        .pagination {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-top: 24px;
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
        .empty-row {
            text-align: center;
            padding: 40px;
            color: #94a3b8;
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
            font-weight: 700;
            margin-bottom: 16px;
        }
        .modal-body input, .modal-body select, .modal-body textarea {
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
        }
    </style>

    <div class="search-bar">
        <div class="search-item">
            <label>商品名称</label>
            <asp:TextBox ID="txtName" runat="server" placeholder="名称关键词" />
        </div>
        <div class="search-item">
            <label>分类</label>
            <asp:DropDownList ID="ddlCategory" runat="server">
                <asp:ListItem Value="" Text="全部分类" />
            </asp:DropDownList>
        </div>
        <div class="search-item">
            <label>状态</label>
            <asp:DropDownList ID="ddlStatus" runat="server">
                <asp:ListItem Value="" Text="全部" />
                <asp:ListItem Value="true" Text="上架" />
                <asp:ListItem Value="false" Text="下架" />
            </asp:DropDownList>
        </div>
        <asp:Button ID="btnSearch" runat="server" Text="搜索" OnClick="btnSearch_Click" />
        <button type="button" class="btn-add" id="btnAddNew">+ 新增商品</button>
    </div>

    <asp:Repeater ID="rptItems" runat="server" OnItemCommand="rptItems_ItemCommand">
        <HeaderTemplate>
            <div class="item-table">
                <table style="width:100%;">
                    <thead>
                        <tr>
                            <th>ID</th><th>图片</th><th>名称</th><th>分类</th><th>价格</th><th>库存</th><th>稀有度</th><th>状态</th><th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
        </HeaderTemplate>
        <ItemTemplate>
            <tr>
                <td><%# Eval("ItemId") %></td>
                <td><img class="item-img" src='<%# Eval("ImageUrl") %>' onerror="this.src='/img/items/default.png'" /></td>
                <td><%# Eval("ItemName") %></td>
                <td><%# Eval("CategoryName") %></td>
                <td>¥<%# Eval("Price", "{0:N2}") %></td>
                <td><%# Eval("Stock") %></td>
                <td><%# Eval("RarityText") %></td>
                <td>
                    <span class='status-badge <%# (bool)Eval("IsAvailable") ? "status-on" : "status-off" %>'>
                        <%# (bool)Eval("IsAvailable") ? "上架" : "下架" %>
                    </span>
                </td>
                <td>
                    <asp:Button ID="btnToggle" runat="server" CommandName="ToggleStatus" CommandArgument='<%# Eval("ItemId") %>'
                        Text='<%# (bool)Eval("IsAvailable") ? "下架" : "上架" %>' CssClass="btn-toggle" />
                    <asp:Button ID="btnEdit" runat="server" CommandName="Edit" CommandArgument='<%# Eval("ItemId") %>' Text="编辑" CssClass="btn-edit" />
                    <asp:Button ID="btnDelete" runat="server" CommandName="Delete" CommandArgument='<%# Eval("ItemId") %>' Text="删除" CssClass="btn-delete" />
                </td>
            </tr>
        </ItemTemplate>
        <FooterTemplate>
                    </tbody>
                </table>
            </div>
            <asp:Literal ID="litEmpty" runat="server" Visible='<%# (rptItems.Items.Count == 0) %>' Text='<div class="empty-row">暂无商品数据</div>' />
        </FooterTemplate>
    </asp:Repeater>

    <div class="pagination" id="paginationDiv" runat="server">
        <asp:Repeater ID="rptPagination" runat="server">
            <ItemTemplate>
                <a href='<%# Eval("Url") %>' class='page-btn <%# Eval("CssClass") %>'><%# Eval("Text") %></a>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <!-- 新增/编辑模态框 -->
    <div id="itemModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span id="modalTitle">新增商品</span>
                <span class="close" id="closeModal">&times;</span>
            </div>
            <div class="modal-body">
                <input type="hidden" id="editItemId" />
                <label>商品名称</label>
                <input type="text" id="itemName" />
                <label>分类</label>
                <select id="itemCategoryId"></select>
                <label>价格</label>
                <input type="number" id="itemPrice" step="0.01" />
                <label>库存</label>
                <input type="number" id="itemStock" />
                <label>稀有度</label>
                <select id="itemRarity">
                    <option value="factory_new">崭新出厂</option>
                    <option value="minimal_wear">略有磨损</option>
                    <option value="field_tested">久经沙场</option>
                    <option value="well_worn">破损不堪</option>
                    <option value="battle_scarred">战痕累累</option>
                </select>
                <label>图片URL</label>
                <input type="text" id="itemImageUrl" placeholder="/img/items/xxx.png" />
                <label>描述</label>
                <textarea id="itemDescription" rows="3"></textarea>
            </div>
            <div class="modal-footer">
                <button class="btn-toggle" id="saveItem">保存</button>
                <button class="btn-delete" id="cancelModal">取消</button>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
    <script>
        // 加载分类下拉框
        function loadCategories() {
            $.ajax({
                url: 'AdminItems.aspx/GetCategories',
                type: 'POST',
                contentType: 'application/json',
                dataType: 'json',
                success: function (res) {
                    var categories = res.d;
                    var html = '<option value="">请选择分类</option>';
                    categories.forEach(function (c) {
                        html += `<option value="${c.CategoryId}">${c.CategoryName}</option>`;
                    });
                    $('#itemCategoryId').html(html);
                }
            });
        }

        // 打开新增模态框
        $('#btnAddNew').click(function () {
            $('#modalTitle').text('新增商品');
            $('#editItemId').val('');
            $('#itemName').val('');
            $('#itemPrice').val('');
            $('#itemStock').val('');
            $('#itemRarity').val('factory_new');
            $('#itemImageUrl').val('');
            $('#itemDescription').val('');
            loadCategories();
            $('#itemModal').css('display', 'flex');
        });

        // 编辑商品
        $('.btn-edit').click(function () {
            var itemId = $(this).attr('commandargument');
            $.ajax({
                url: 'AdminItems.aspx/GetItem',
                type: 'POST',
                data: JSON.stringify({ itemId: itemId }),
                contentType: 'application/json',
                dataType: 'json',
                success: function (res) {
                    var item = res.d;
                    $('#modalTitle').text('编辑商品');
                    $('#editItemId').val(item.ItemId);
                    $('#itemName').val(item.ItemName);
                    $('#itemPrice').val(item.Price);
                    $('#itemStock').val(item.Stock);
                    $('#itemRarity').val(item.Rarity);
                    $('#itemImageUrl').val(item.ImageUrl);
                    $('#itemDescription').val(item.Description);
                    loadCategories();
                    $('#itemCategoryId').val(item.CategoryId);
                    $('#itemModal').css('display', 'flex');
                }
            });
        });

        $('#saveItem').click(function () {
            var data = {
                ItemId: $('#editItemId').val(),
                ItemName: $('#itemName').val(),
                CategoryId: $('#itemCategoryId').val(),
                Price: $('#itemPrice').val(),
                Stock: $('#itemStock').val(),
                Rarity: $('#itemRarity').val(),
                ImageUrl: $('#itemImageUrl').val(),
                Description: $('#itemDescription').val()
            };
            $.ajax({
                url: 'AdminItems.aspx/SaveItem',
                type: 'POST',
                data: JSON.stringify(data),
                contentType: 'application/json',
                success: function (res) {
                    if (res.d.success) {
                        alert('保存成功');
                        location.reload();
                    } else {
                        alert('保存失败：' + res.d.message);
                    }
                }
            });
        });

        $('#closeModal, #cancelModal').click(function () {
            $('#itemModal').css('display', 'none');
        });
    </script>
</asp:Content>