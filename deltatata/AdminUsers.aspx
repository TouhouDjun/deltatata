<%@ Page Title="用户管理" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="AdminUsers.aspx.cs" Inherits="DeltaTradeHub.AdminUsers" %>

<asp:Content ID="Content1" ContentPlaceHolderID="PageTitle" runat="server">
    用户管理
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
            align-items: center;
            flex-wrap: wrap;
        }
        .search-bar input {
            flex: 1;
            padding: 8px 14px;
            border: 1px solid #e2e8f0;
            border-radius: 30px;
        }
        .search-bar button {
            background: #ff7e00;
            border: none;
            border-radius: 30px;
            padding: 8px 24px;
            color: white;
            cursor: pointer;
        }
        .user-table {
            width: 100%;
            background: white;
            border-radius: 16px;
            overflow: hidden;
            border: 1px solid #edf2f7;
        }
        .user-table th {
            background: #f8fafc;
            padding: 12px 16px;
            text-align: left;
            font-weight: 600;
            color: #1e293b;
            border-bottom: 1px solid #edf2f7;
        }
        .user-table td {
            padding: 12px 16px;
            border-bottom: 1px solid #edf2f7;
            vertical-align: middle;
        }
        .status-badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 20px;
            font-size: 12px;
        }
        .status-active {
            background: #dcfce7;
            color: #15803d;
        }
        .status-disabled {
            background: #fee2e2;
            color: #b91c1c;
        }
        .btn-toggle {
            background: #ff7e00;
            border: none;
            border-radius: 20px;
            padding: 4px 12px;
            color: white;
            cursor: pointer;
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
    </style>

    <div class="search-bar">
        <asp:TextBox ID="txtSearch" runat="server" placeholder="用户名/邮箱" />
        <asp:Button ID="btnSearch" runat="server" Text="搜索" OnClick="btnSearch_Click" />
    </div>

    <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
        <HeaderTemplate>
            <table class="user-table">
                <thead>
                    <tr>
                        <th>ID</th><th>用户名</th><th>邮箱</th><th>余额</th><th>注册时间</th><th>状态</th><th>操作</th>
                    </tr>
                </thead>
                <tbody>
        </HeaderTemplate>
        <ItemTemplate>
            <tr>
                <td><%# Eval("UserId") %></td>
                <td><%# Eval("Username") %></td>
                <td><%# Eval("Email") %></td>
                <td>¥<%# Eval("Balance", "{0:N2}") %></td>
                <td><%# Eval("RegisterDate", "{0:yyyy-MM-dd}") %></td>
                <td>
                    <span class='status-badge <%# (bool)Eval("IsActive") ? "status-active" : "status-disabled" %>'>
                        <%# (bool)Eval("IsActive") ? "正常" : "禁用" %>
                    </span>
                </td>
                <td>
                    <asp:Button ID="btnToggle" runat="server" CommandName="ToggleStatus" CommandArgument='<%# Eval("UserId") %>'
                        Text='<%# (bool)Eval("IsActive") ? "禁用" : "启用" %>'
                        CssClass="btn-toggle" Visible='<%# Eval("Username").ToString() != "admin1" %>' />
                </td>
            </tr>
        </ItemTemplate>
        <FooterTemplate>
                </tbody>
            </table>
            <asp:Literal ID="litEmpty" runat="server" Visible='<%# (rptUsers.Items.Count == 0) %>' Text='<div class="empty-row">暂无用户数据</div>' />
        </FooterTemplate>
    </asp:Repeater>

    <div class="pagination" id="paginationDiv" runat="server">
        <asp:Repeater ID="rptPagination" runat="server">
            <ItemTemplate>
                <a href='<%# Eval("Url") %>' class='page-btn <%# Eval("CssClass") %>'><%# Eval("Text") %></a>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Content>