<%@ Page Title="文章投稿 - 塔科夫交易行" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PostArticle.aspx.cs" Inherits="DeltaTradeHub.PostArticle" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .post-container {
            max-width: 800px;
            margin: 40px auto;
            background: white;
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        }
        .post-title {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 24px;
            color: #1e293b;
            border-left: 4px solid #ff7e00;
            padding-left: 16px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
            color: #334155;
        }
        .form-control {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            font-size: 14px;
            transition: 0.2s;
        }
        .form-control:focus {
            border-color: #ff7e00;
            outline: none;
            box-shadow: 0 0 0 3px rgba(255,126,0,0.1);
        }
        textarea.form-control {
            min-height: 200px;
            resize: vertical;
        }
        .btn-submit {
            background: #ff7e00;
            color: white;
            border: none;
            border-radius: 40px;
            padding: 12px 24px;
            font-weight: 600;
            cursor: pointer;
            transition: 0.2s;
        }
        .btn-submit:hover {
            background: #e66900;
        }
        .help-text {
            font-size: 12px;
            color: #64748b;
            margin-top: 4px;
        }
        .error-msg {
            color: #dc3545;
            font-size: 13px;
            margin-top: 4px;
        }
    </style>

    <div class="post-container">
        <div class="post-title">📝 文章投稿</div>

        <asp:Panel ID="pnlForm" runat="server">
            <div class="form-group">
                <label class="form-label">标题 *</label>
                <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" MaxLength="200" />
                <asp:RequiredFieldValidator ID="rfvTitle" ControlToValidate="txtTitle" Display="Dynamic" ErrorMessage="请输入标题" CssClass="error-msg" runat="server" />
            </div>

            <div class="form-group">
                <label class="form-label">分类 *</label>
                <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control">
                    <asp:ListItem Text="CS2" Value="CS2" Selected="True" />
                    <asp:ListItem Text="DOTA2" Value="DOTA2" />
                </asp:DropDownList>
            </div>

            <div class="form-group">
                <label class="form-label">作者 *</label>
                <asp:TextBox ID="txtAuthor" runat="server" CssClass="form-control" MaxLength="100" />
                <asp:RequiredFieldValidator ID="rfvAuthor" ControlToValidate="txtAuthor" Display="Dynamic" ErrorMessage="请输入作者" CssClass="error-msg" runat="server" />
            </div>

            <div class="form-group">
                <label class="form-label">来源 *</label>
                <asp:TextBox ID="txtSource" runat="server" CssClass="form-control" MaxLength="100" Text="BUFF" />
                <asp:RequiredFieldValidator ID="rfvSource" ControlToValidate="txtSource" Display="Dynamic" ErrorMessage="请输入来源" CssClass="error-msg" runat="server" />
            </div>

            <div class="form-group">
                <label class="form-label">正文 *</label>
                <asp:TextBox ID="txtContent" runat="server" TextMode="MultiLine" CssClass="form-control" />
                <asp:RequiredFieldValidator ID="rfvContent" ControlToValidate="txtContent" Display="Dynamic" ErrorMessage="请输入正文" CssClass="error-msg" runat="server" />
                <div class="help-text">支持HTML标记，建议使用纯文本换行。</div>
            </div>

            <div class="form-group">
                <label class="form-label">缩略图URL（可选）</label>
                <asp:TextBox ID="txtImageUrl" runat="server" CssClass="form-control" placeholder="/img/news/xxx.jpg" />
                <div class="help-text">请输入图片地址，留空则使用默认占位图</div>
            </div>

            <div class="form-group">
                <asp:Button ID="btnSubmit" runat="server" Text="提交审核" CssClass="btn-submit" OnClick="btnSubmit_Click" />
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
            <div style="text-align:center; padding: 40px;">
                <div style="font-size: 48px;">✅</div>
                <h3>投稿成功！</h3>
                <p>您的文章已提交，管理员审核后将会显示在资讯列表。</p>
                <a href="News.aspx" class="btn-submit" style="display:inline-block; text-decoration:none;">返回资讯列表</a>
            </div>
        </asp:Panel>
    </div>
</asp:Content>