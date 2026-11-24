<%@ Page Title="订单管理" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="AdminOrders.aspx.cs" Inherits="DeltaTradeHub.AdminOrders" %>

<asp:Content ID="Content1" ContentPlaceHolderID="PageTitle" runat="server">
    订单管理
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
        .search-bar input, .search-bar select, .search-bar button {
            padding: 8px 16px;
            border-radius: 30px;
            border: 1px solid #e2e8f0;
        }
        .search-bar button {
            background: #ff7e00;
            color: white;
            border: none;
            cursor: pointer;
        }
        .order-table {
            width: 100%;
            background: white;
            border-radius: 16px;
            overflow-x: auto;
            border: 1px solid #edf2f7;
        }
        .order-table th {
            background: #f8fafc;
            padding: 12px 16px;
            text-align: left;
            font-weight: 600;
            border-bottom: 1px solid #edf2f7;
        }
        .order-table td {
            padding: 12px 16px;
            border-bottom: 1px solid #edf2f7;
        }
        .status-badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 20px;
            font-size: 12px;
        }
        .status-approved {
            background: #dcfce7;
            color: #15803d;
        }
        .status-pending {
            background: #fef3c7;
            color: #d97706;
        }
        .status-rejected {
            background: #fee2e2;
            color: #b91c1c;
        }
        .btn-detail {
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
        <asp:TextBox ID="txtKeyword" runat="server" placeholder="用户名/商品名" />
        <asp:DropDownList ID="ddlStatus" runat="server">
            <asp:ListItem Text="全部" Value="" />
            <asp:ListItem Text="已完成" Value="Completed" />
            <asp:ListItem Text="待支付" Value="Pending" />
            <asp:ListItem Text="已取消" Value="Cancelled" />
        </asp:DropDownList>
        <asp:Button ID="btnSearch" runat="server" Text="搜索" OnClick="btnSearch_Click" />
    </div>

    <div class="order-table">
        <asp:Repeater ID="rptOrders" runat="server">
            <HeaderTemplate>
                <table style="width:100%">
                    <thead>
                        <tr><th>商品</th><th>数量</th><th>单价</th><th>总价</th><th>状态</th><th>时间</th><th>操作</th></tr>
                    </thead>
                    <tbody>
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td><%# Eval("ItemName") %></td>
                    <td><%# Eval("Quantity") %></td>
                    <td><%# Eval("UnitPrice", "{0:N2}") %></td>
                    <td><%# Eval("TotalAmount", "{0:N2}") %></td>
                    <td>
                        <span class='status-badge status-<%# GetStatusClass(Eval("Status").ToString()) %>'>
                            <%# Eval("Status").ToString() == "Completed" ? "已完成" : (Eval("Status").ToString() == "Pending" ? "待支付" : "已取消") %>
                        </span>
                    </td>
                    <td><%# Eval("TransactionDate", "{0:yyyy-MM-dd HH:mm}") %></td>
                    <td><button class="btn-detail" onclick="alert('订单详情开发中')">详情</button></td>
                </tr>
            </ItemTemplate>
            <FooterTemplate>
                    </tbody>
                </table>
                <asp:Literal ID="litEmpty" runat="server" Visible='<%# (rptOrders.Items.Count == 0) %>' Text='<div class="empty-row">暂无订单</div>' />
            </FooterTemplate>
        </asp:Repeater>
    </div>

    <div class="pagination" id="paginationDiv" runat="server">
        <asp:Repeater ID="rptPagination" runat="server">
            <ItemTemplate>
                <a href='<%# Eval("Url") %>' class='page-btn <%# Eval("CssClass") %>'><%# Eval("Text") %></a>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Content>