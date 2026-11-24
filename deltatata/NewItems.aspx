<%@ Page Title="最新上架" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NewItems.aspx.cs" Inherits="DeltaTradeHub.NewItems" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* 复用Market.aspx的样式，保证风格统一 */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: "Microsoft YaHei", sans-serif;
        }
        body {
            background-color: #f5f5f7;
        }
        /* 返回按钮+页面标题 */
        .page-header {
            display: flex;
            align-items: center;
            margin-bottom: 24px;
            padding-bottom: 16px;
            border-bottom: 1px solid #f1f5f9;
        }
        .back-btn {
            background-color: #ff7e00;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            margin-right: 12px;
            text-decoration: none;
            display: inline-block;
        }
        .back-btn:hover {
            background-color: #e66900;
            color: white;
        }
        .page-title {
            font-size: 24px;
            font-weight: 700;
            color: #1e293b;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .page-title i {
            color: #ff7e00;
        }
        /* 饰品网格（和Market.aspx完全一致） */
        .item-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }
        /* 饰品卡片（复用Market.aspx的BUFF风格） */
        .item-card {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 1px 2px rgba(0,0,0,0.06);
            transition: all 0.3s ease;
            cursor: pointer;
            position: relative;
        }
        .item-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 16px rgba(0,0,0,0.1);
        }
        .item-img-container {
            width: 100%;
            height: 180px;
            background-color: #f8fafc;
            position: relative;
            overflow: hidden;
        }
        .item-img {
            width: 100%;
            height: 100%;
            object-fit: contain;
            padding: 16px;
            transition: transform 0.3s ease;
        }
        .item-card:hover .item-img {
            transform: scale(1.05);
        }
        .wear-tag {
            position: absolute;
            top: 8px;
            left: 8px;
            background: rgba(0,0,0,0.7);
            color: white;
            font-size: 10px;
            padding: 2px 6px;
            border-radius: 4px;
        }
        .sticker-tag {
            position: absolute;
            bottom: 8px;
            right: 8px;
            background: #ff7e00;
            color: white;
            font-size: 10px;
            padding: 2px 6px;
            border-radius: 4px;
        }
        .item-card-content {
            padding: 12px;
        }
        .item-name {
            font-size: 13px;
            font-weight: 500;
            color: #1e293b;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            margin-bottom: 4px;
        }
        .item-price {
            font-size: 16px;
            font-weight: 700;
            color: #ff7e00;
            margin-bottom: 4px;
        }
        .item-meta {
            display: flex;
            justify-content: space-between;
            font-size: 11px;
            color: #94a3b8;
            margin-bottom: 8px;
        }
        /* 新增：上架时间展示 */
        .item-create-time {
            font-size: 11px;
            color: #64748b;
            margin-bottom: 8px;
        }
        .item-actions {
            display: flex;
            gap: 8px;
        }
        .btn-buy {
            flex: 1;
            background-color: #ff7e00;
            color: white;
            border: none;
            border-radius: 6px;
            padding: 6px 0;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .btn-buy:hover {
            background-color: #e66900;
        }
        .btn-cart {
            flex: 1;
            background-color: #f8fafc;
            color: #1e293b;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            padding: 6px 0;
            font-size: 12px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-cart:hover {
            background-color: #f1f5f9;
            border-color: #cbd5e1;
        }
        /* 分页（复用BUFF风格） */
        .pagination {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin: 24px 0;
        }
        .page-btn {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #f8fafc;
            color: #64748b;
            text-decoration: none;
            font-size: 14px;
            transition: all 0.2s;
        }
        .page-btn:hover {
            background-color: #e2e8f0;
            color: #1e293b;
        }
        .page-btn.active {
            background-color: #ff7e00;
            color: white;
        }
        /* 无数据提示 */
        .no-data {
            text-align: center;
            font-size: 18px;
            color: #94a3b8;
            padding: 50px 0;
            background: white;
            border-radius: 12px;
            margin: 20px 0;
        }
        /* 加载动画 */
        .loading {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: rgba(0,0,0,0.7);
            color: white;
            padding: 12px 24px;
            border-radius: 8px;
            z-index: 1000;
            display: none;
        }
        .loading.show {
            display: block;
        }
    </style>

    <!-- 页面标题+返回按钮 -->
    <div class="page-header">
        <a href="Market.aspx" class="back-btn">← 返回首页</a>
        <div class="page-title">
            <i>🆕</i> 最新上架饰品
        </div>
    </div>

    <!-- 无数据提示 -->
    <asp:Literal ID="litNoData" runat="server" Visible="false" Text='<div class="no-data">暂无最新上架饰品</div>' />

    <!-- 最新上架饰品列表 -->
    <div class="item-grid">
        <asp:Repeater ID="rptNewItems" runat="server">
            <ItemTemplate>
                <div class="item-card" data-itemid='<%# Eval("ItemId") %>'>
                    <div class="item-img-container">
                        <%-- 核心修复：图片路径 + 默认图兜底 + onerror容错 --%>
                        <img class="item-img" 
                             src='<%# !string.IsNullOrEmpty(Eval("ImageUrl")?.ToString()) && Eval("ImageUrl").ToString().StartsWith("/img/") ? Eval("ImageUrl") : "/img/items/default.png" %>' 
                             alt='<%# Eval("ItemName") %>'
                             onerror="this.src='/img/items/default.png'">
                        <div class="wear-tag"><%# GetWearText((string)Eval("Rarity")) %></div>
                        <% if (new Random().Next(0, 2) == 1) { %>
                            <div class="sticker-tag">印花×<%= new Random().Next(1, 4) %></div>
                        <% } %>
                    </div>
                    <div class="item-card-content">
                        <div class="item-name"><%# Eval("ItemName") %></div>
                        <div class="item-price"><%# Eval("Price", "¥{0:N2}") %></div>
                        <div class="item-meta">
                            <div class="item-wear"><%# GetWearDesc((string)Eval("Rarity")) %></div>
                            <div class="item-stock">库存: <%# Eval("Stock") %></div>
                        </div>
                        <!-- 新增：上架时间 -->
                        <div class="item-create-time">上架时间: <%# Convert.ToDateTime(Eval("CreateDate")).ToString("yyyy-MM-dd HH:mm") %></div>
                        <div class="item-actions">
                            <button class="btn-buy buy-now" data-id='<%# Eval("ItemId") %>'>立即购买</button>
                            <button class="btn-cart add-cart" data-id='<%# Eval("ItemId") %>'>加入购物车</button>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <!-- 分页 -->
    <div class="pagination">
        <asp:Repeater ID="rptPagination" runat="server">
            <ItemTemplate>
                <a href='<%# Eval("Url") %>' class='page-btn <%# Eval("CssClass") %>'><%# Eval("Text") %></a>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <!-- 加载动画 -->
    <div class="loading" id="loading">处理中...</div>

    <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
    <script>
        $(function () {
            // 显示/隐藏加载
            function showLoading(show) {
                if (show) {
                    $('#loading').addClass('show');
                } else {
                    $('#loading').removeClass('show');
                }
            }

            // 立即购买（和Market.aspx逻辑一致）
            $('.buy-now').click(function () {
                var itemId = $(this).data('id');
                if (confirm('确定购买该饰品吗？')) {
                    showLoading(true);
                    $.ajax({
                        url: 'NewItems.aspx/DirectPurchase',
                        type: 'POST',
                        contentType: 'application/json; charset=utf-8',
                        data: JSON.stringify({ itemId: itemId }),
                        success: function (res) {
                            showLoading(false);
                            if (res.d.success) {
                                alert('购买成功！');
                                window.location.reload();
                            } else {
                                alert('购买失败：' + res.d.message);
                            }
                        },
                        error: function () {
                            showLoading(false);
                            alert('网络错误，购买失败');
                        }
                    });
                }
            });

            // 加入购物车（和Market.aspx逻辑一致）
            $('.add-cart').click(function () {
                var itemId = $(this).data('id');
                showLoading(true);
                $.ajax({
                    url: 'NewItems.aspx/AddCart',
                    type: 'POST',
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ itemId: itemId }),
                    success: function (res) {
                        showLoading(false);
                        if (res.d.success) {
                            alert('已加入购物车');
                        } else {
                            alert(res.d.message);
                        }
                    },
                    error: function () {
                        showLoading(false);
                        alert('加入购物车失败');
                    }
                });
            });
        });
    </script>
</asp:Content>