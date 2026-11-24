<%@ Page Title="充值审核" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="AdminRecharge.aspx.cs" Inherits="DeltaTradeHub.AdminRecharge" %>

<asp:Content ID="Content1" ContentPlaceHolderID="PageTitle" runat="server">
    充值审核
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
        .search-bar select, .search-bar button {
            padding: 8px 16px;
            border-radius: 30px;
            border: 1px solid #e2e8f0;
            background: white;
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
            overflow: hidden;
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
        .status-pending {
            background: #fef3c7;
            color: #d97706;
        }
        .status-approved {
            background: #dcfce7;
            color: #15803d;
        }
        .status-rejected {
            background: #fee2e2;
            color: #b91c1c;
        }
        .btn-approve {
            background: #10b981;
            border: none;
            border-radius: 20px;
            padding: 4px 12px;
            color: white;
            cursor: pointer;
            margin-right: 8px;
        }
        .btn-reject {
            background: #ef4444;
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
        .toast {
            position: fixed;
            bottom: 30px;
            left: 50%;
            transform: translateX(-50%);
            background: #28a745;
            color: white;
            padding: 10px 20px;
            border-radius: 40px;
            z-index: 1100;
            display: none;
        }
    </style>

    <div class="search-bar">
        <asp:DropDownList ID="ddlStatus" runat="server">
        </asp:DropDownList>
        <asp:Button ID="btnSearch" runat="server" Text="筛选" OnClick="btnSearch_Click" />
    </div>

    <asp:Repeater ID="rptRecharge" runat="server" OnItemCommand="rptRecharge_ItemCommand">
        <HeaderTemplate>
            <table class="order-table">
                <thead>
                    <tr>
                        <th>ID</th><th>用户</th><th>金额</th><th>申请时间</th><th>状态</th><th>操作</th>
                    </tr>
                </thead>
                <tbody>
        </HeaderTemplate>
        <ItemTemplate>
            <tr>
                <td><%# Eval("Id") %></td>
                <td><%# Eval("Username") %></td>
                <td>¥<%# Eval("Amount", "{0:N2}") %></td>
                <td><%# Eval("CreateTime", "{0:yyyy-MM-dd HH:mm}") %></td>
                <td>
                    <span class='status-badge status-<%# Eval("Status").ToString().Trim().ToLower() %>'>
                        <%# Eval("Status").ToString().Trim() == "Pending" ? "待审核" : (Eval("Status").ToString().Trim() == "Approved" ? "已通过" : "已拒绝") %>
                    </span>
                </td>
                <td>
                    <asp:Button ID="btnApprove" runat="server" CommandName="Approve" CommandArgument='<%# Eval("Id") %>'
                        Text="通过" CssClass="btn-approve" 
                        Visible='<%# Eval("Status").ToString().Trim().ToLower() == "pending" %>' />
                    <asp:Button ID="btnReject" runat="server" CommandName="Reject" CommandArgument='<%# Eval("Id") %>'
                        Text="拒绝" CssClass="btn-reject" 
                        Visible='<%# Eval("Status").ToString().Trim().ToLower() == "pending" %>' />
                    
                    <asp:Literal ID="litNoAction" runat="server" Text="-" 
                        Visible='<%# Eval("Status").ToString().Trim().ToLower() != "pending" %>' />
                 </td>
            </tr>
        </ItemTemplate>
        <FooterTemplate>
                </tbody>
            </table>
            <asp:Literal ID="litEmpty" runat="server" Visible='<%# (rptRecharge.Items.Count == 0) %>' Text='<div class="empty-row">暂无充值记录</div>' />
        </FooterTemplate>
    </asp:Repeater>

    <div class="pagination" id="paginationDiv" runat="server">
        <asp:Repeater ID="rptPagination" runat="server">
            <ItemTemplate>
                <a href='<%# Eval("Url") %>' class='page-btn <%# Eval("CssClass") %>'><%# Eval("Text") %></a>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <div class="toast" id="toastMsg"></div>

    <script src="Scripts/jquery-3.7.0.min.js"></script>
    <script>
        function showToast(msg, isError) {
            var toast = $('#toastMsg');
            toast.text(msg);
            toast.css('background-color', isError ? '#dc3545' : '#28a745');
            toast.fadeIn(200);
            setTimeout(function () {
                toast.fadeOut(200);
            }, 3000);
        }
    </script>
</asp:Content>