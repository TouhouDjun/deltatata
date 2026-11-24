<%@ Page Title="系统设置" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="AdminSettings.aspx.cs" Inherits="DeltaTradeHub.AdminSettings" %>

<asp:Content ID="Content1" ContentPlaceHolderID="PageTitle" runat="server">
    系统设置
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .settings-container {
            max-width: 600px;
            background: white;
            border-radius: 20px;
            padding: 24px;
            margin: 0 auto;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
            color: #334155;
        }
        .form-group input, .form-group textarea {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            font-size: 14px;
        }
        .form-group textarea {
            min-height: 80px;
            resize: vertical;
        }
        .btn-save {
            background: #ff7e00;
            color: white;
            border: none;
            border-radius: 40px;
            padding: 10px 24px;
            font-weight: 600;
            cursor: pointer;
        }
        .btn-save:hover {
            background: #e66900;
        }
        .divider {
            height: 1px;
            background: #edf2f7;
            margin: 24px 0;
        }
        .help-text {
            font-size: 12px;
            color: #64748b;
            margin-top: 4px;
        }
    </style>

    <div class="settings-container">
        <h3 style="margin-bottom: 20px;">⚙️ 基础设置</h3>
        
        <div class="form-group">
            <label>平台名称</label>
            <asp:TextBox ID="txtPlatformName" runat="server" CssClass="form-control" />
        </div>

        <div class="form-group">
            <label>客服邮箱</label>
            <asp:TextBox ID="txtCustomerService" runat="server" CssClass="form-control" />
            <div class="help-text">用于用户联系客服</div>
        </div>

        <div class="form-group">
            <label>交易手续费率</label>
            <asp:TextBox ID="txtFeeRate" runat="server" CssClass="form-control" />
            <div class="help-text">例如 0.05 表示 5%，用于订单结算时扣除</div>
        </div>

        <div class="divider"></div>

        <h3 style="margin-bottom: 20px;">🔐 安全设置</h3>
        <div class="form-group">
            <label>当前管理员密码</label>
            <asp:TextBox ID="txtOldPassword" runat="server" TextMode="Password" CssClass="form-control" />
        </div>
        <div class="form-group">
            <label>新密码</label>
            <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" CssClass="form-control" />
        </div>
        <div class="form-group">
            <label>确认新密码</label>
            <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="form-control" />
        </div>

        <div class="divider"></div>

        <div class="form-group">
            <label>后台登录公告</label>
            <asp:TextBox ID="txtAdminNotice" runat="server" TextMode="MultiLine" CssClass="form-control" />
        </div>

        <asp:Button ID="btnSave" runat="server" Text="保存设置" CssClass="btn-save" OnClick="btnSave_Click" />
    </div>
</asp:Content>