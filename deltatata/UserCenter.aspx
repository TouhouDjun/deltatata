<%@ Page Title="个人中心" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UserCenter.aspx.cs" Inherits="DeltaTradeHub.UserCenter" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .user-center-container {
            max-width: 1100px;
            margin: 20px auto;
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            overflow: hidden;
            display: flex;
        }
        .user-sidebar {
            width: 240px;
            background: #1e293b;
            color: #fff;
            padding: 24px 0;
        }
        .user-avatar-big {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: #ff7e00;
            margin: 0 auto 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            font-weight: bold;
        }
        .user-name {
            text-align: center;
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 6px;
        }
        .user-balance {
            text-align: center;
            font-size: 13px;
            color: #ffd966;
            margin-bottom: 24px;
        }
        .sidebar-menu {
            list-style: none;
            padding: 0;
        }
        .sidebar-menu li {
            padding: 12px 24px;
            font-size: 14px;
            cursor: pointer;
            transition: 0.2s;
            border-left: 3px solid transparent;
        }
        .sidebar-menu li.active {
            background: #ff7e00;
            border-left-color: #fff;
        }
        .sidebar-menu li:hover:not(.active) {
            background: #334155;
        }
        .user-content {
            flex: 1;
            padding: 24px;
            background: #fff;
        }
        .back-btn {
            display: inline-block;
            background: #ff7e00;
            color: white;
            padding: 6px 16px;
            border-radius: 20px;
            text-decoration: none;
            font-size: 13px;
            margin-bottom: 20px;
        }
        .back-btn:hover {
            background: #e66900;
        }
        .section-title {
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 20px;
            padding-bottom: 8px;
            border-bottom: 2px solid #f1f5f9;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 28px;
        }
        .stat-card {
            background: #f8fafc;
            border-radius: 12px;
            padding: 16px;
            text-align: center;
        }
        .stat-title {
            font-size: 13px;
            color: #64748b;
            margin-bottom: 6px;
        }
        .stat-number {
            font-size: 26px;
            font-weight: 700;
            color: #1e293b;
        }
        .stat-number.orange {
            color: #ff7e00;
        }
        .form-card {
            background: #f8fafc;
            border-radius: 12px;
            padding: 20px;
        }
        .form-row {
            margin-bottom: 16px;
        }
        .form-label {
            display: block;
            font-size: 13px;
            color: #64748b;
            margin-bottom: 4px;
        }
        .form-control {
            width: 280px;
            padding: 8px 12px;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            font-size: 14px;
            background: #fff;
        }
        .form-control:disabled {
            background: #f1f5f9;
        }
        .btn-primary {
            background: #ff7e00;
            color: white;
            border: none;
            padding: 8px 20px;
            border-radius: 30px;
            cursor: pointer;
            font-weight: 600;
        }
        .data-table {
            width: 100%;
            border-collapse: collapse;
        }
        .data-table th, .data-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #edf2f7;
        }
        .data-table th {
            background: #f8fafc;
            font-weight: 600;
        }
        .empty-msg {
            text-align: center;
            padding: 40px;
            color: #94a3b8;
        }
        .tab-pane {
            display: none;
        }
        .tab-pane.active {
            display: block;
        }
    </style>

    <div class="user-center-container">
        <div class="user-sidebar">
            <div class="user-avatar-big"><asp:Literal ID="litAvatarChar" runat="server"></asp:Literal></div>
            <div class="user-name"><asp:Literal ID="litUsername" runat="server"></asp:Literal></div>
            <div class="user-balance">账户余额：¥<asp:Literal ID="litBalance" runat="server"></asp:Literal></div>
            <ul class="sidebar-menu" id="sidebarMenu">
                <li data-tab="profile" class="active">个人信息</li>
                <li data-tab="orders">我的订单</li>
                <li data-tab="items">我的饰品</li>
                <li data-tab="buyOrders">求购记录</li>
                <li data-tab="security">账户安全</li>
            </ul>
        </div>
        <div class="user-content">
            <a href="Market.aspx" class="back-btn">← 返回首页</a>

            <!-- 个人信息面板 -->
            <div id="tab-profile" class="tab-pane active">
                <div class="section-title">个人信息</div>
                <div class="stats-grid">
                    <div class="stat-card"><div class="stat-title">已购饰品</div><div class="stat-number"><asp:Literal ID="litBoughtCount" runat="server"></asp:Literal></div></div>
                    <div class="stat-card"><div class="stat-title">在售饰品</div><div class="stat-number"><asp:Literal ID="litSellingCount" runat="server"></asp:Literal></div></div>
                    <div class="stat-card"><div class="stat-title">待处理订单</div><div class="stat-number orange"><asp:Literal ID="litPendingOrders" runat="server"></asp:Literal></div></div>
                </div>
                <div class="form-card">
                    <div class="form-row"><label class="form-label">用户名</label><asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" Enabled="false" /></div>
                    <div class="form-row"><label class="form-label">邮箱</label><asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" Enabled="false" /></div>
                    <div class="form-row"><label class="form-label">注册时间</label><asp:TextBox ID="txtRegisterDate" runat="server" CssClass="form-control" Enabled="false" /></div>
                    <asp:Button ID="btnEditProfile" runat="server" Text="修改信息" CssClass="btn-primary" OnClick="btnEditProfile_Click" />
                </div>
            </div>

            <!-- 我的订单面板 -->
            <div id="tab-orders" class="tab-pane">
                <div class="section-title">我的订单</div>
                <asp:Repeater ID="rptOrders" runat="server">
                    <HeaderTemplate><table class="data-table"><tr><th>时间</th><th>物品</th><th>数量</th><th>单价</th><th>总金额</th><th>状态</th></tr></HeaderTemplate>
                    <ItemTemplate><tr><td><%# Eval("TransactionDate", "{0:yyyy-MM-dd HH:mm}") %></td><td><%# Eval("ItemName") %></td><td><%# Eval("Quantity") %></td><td><%# Eval("UnitPrice", "{0:C}") %></td><td><%# Eval("TotalAmount", "{0:C}") %></td><td><%# Eval("Status") %></td></tr></ItemTemplate>
                    <FooterTemplate></table></FooterTemplate>
                </asp:Repeater>
                <asp:Literal ID="litEmptyOrders" runat="server" Visible="false" Text="<div class='empty-msg'>暂无交易记录</div>" />
            </div>

            <!-- 我的饰品面板 -->
            <div id="tab-items" class="tab-pane">
                <div class="section-title">我的饰品</div>
                <asp:Repeater ID="rptInventory" runat="server">
                    <HeaderTemplate><table class="data-table"><tr><th>名称</th><th>数量</th><th>单价</th><th>稀有度</th></tr></HeaderTemplate>
                    <ItemTemplate><tr><td><%# Eval("ItemName") %></td><td><%# Eval("Quantity") %></td><td><%# Eval("Price", "{0:C}") %></td><td><%# Eval("Rarity") %></td></tr></ItemTemplate>
                    <FooterTemplate></table><div style="margin-top:16px;"><a href="Storehouse.aspx" class="btn-primary" style="display:inline-block;text-decoration:none;padding:8px 20px;">管理仓库</a></div></FooterTemplate>
                </asp:Repeater>
                <asp:Literal ID="litEmptyInventory" runat="server" Visible="false" Text="<div class='empty-msg'>暂无饰品库存</div>" />
            </div>

            <!-- 求购记录面板 -->
            <div id="tab-buyOrders" class="tab-pane">
                <div class="section-title">求购记录</div>
                <asp:Repeater ID="rptBuyOrders" runat="server">
                    <HeaderTemplate><table class="data-table"><tr><th>物品</th><th>数量</th><th>单价</th><th>状态</th><th>发布时间</th></tr></HeaderTemplate>
                    <ItemTemplate><tr><td><%# Eval("ItemName") %></td><td><%# Eval("Quantity") %></td><td><%# Eval("Price", "{0:C}") %></td><td><%# Eval("Status") %></td><td><%# Eval("CreateDate", "{0:yyyy-MM-dd}") %></td></tr></ItemTemplate>
                    <FooterTemplate></table></FooterTemplate>
                </asp:Repeater>
                <asp:Literal ID="litEmptyBuyOrders" runat="server" Visible="false" Text="<div class='empty-msg'>暂无求购记录</div>" />
            </div>

            <!-- 账户安全面板 -->
            <div id="tab-security" class="tab-pane">
                <div class="section-title">账户安全</div>
                <div class="form-card">
                    <div class="form-row"><label class="form-label">绑定邮箱</label><asp:TextBox ID="txtSecurityEmail" runat="server" CssClass="form-control" Enabled="false" /></div>
                    <div class="form-row"><label class="form-label">修改密码</label><asp:Button ID="btnChangePwd" runat="server" Text="前往修改" CssClass="btn-primary" OnClick="btnChangePwd_Click" /></div>
                    <div class="form-row"><label class="form-label">绑定手机</label><asp:Button ID="btnBindPhone" runat="server" Text="绑定" CssClass="btn-primary" OnClick="btnBindPhone_Click" /></div>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        // 确保 jQuery 已加载，使用原生 JavaScript 备用
        document.addEventListener('DOMContentLoaded', function () {
            var menuItems = document.querySelectorAll('#sidebarMenu li');
            var panes = document.querySelectorAll('.tab-pane');
            function switchTab(tabId) {
                panes.forEach(function (pane) {
                    pane.classList.remove('active');
                });
                var activePane = document.getElementById('tab-' + tabId);
                if (activePane) activePane.classList.add('active');
                menuItems.forEach(function (item) {
                    item.classList.remove('active');
                    if (item.getAttribute('data-tab') === tabId) {
                        item.classList.add('active');
                    }
                });
            }
            menuItems.forEach(function (item) {
                item.addEventListener('click', function (e) {
                    var tabId = this.getAttribute('data-tab');
                    switchTab(tabId);
                });
            });
            // 默认激活个人信息
            switchTab('profile');
        });
    </script>
</asp:Content>