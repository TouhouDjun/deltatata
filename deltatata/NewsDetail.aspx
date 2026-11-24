<%@ Page Title="新闻详情 - 塔科夫交易行" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NewsDetail.aspx.cs" Inherits="DeltaTradeHub.NewsDetail" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .detail-container {
            max-width: 900px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            color: #ff7e00;
            text-decoration: none;
            font-size: 14px;
        }
        .back-link:hover {
            text-decoration: underline;
        }
        .article {
            background: white;
            border-radius: 16px;
            padding: 30px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        .article-title {
            font-size: 28px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 16px;
            line-height: 1.3;
        }
        .article-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            font-size: 14px;
            color: #64748b;
            padding-bottom: 16px;
            border-bottom: 1px solid #edf2f7;
            margin-bottom: 24px;
        }
        .article-meta span {
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .article-meta .source {
            color: #ff7e00;
        }
        .article-img {
            width: 100%;
            max-height: 400px;
            object-fit: cover;
            border-radius: 12px;
            margin-bottom: 24px;
        }
        .article-content {
            font-size: 16px;
            line-height: 1.7;
            color: #334155;
        }
        .article-content p {
            margin-bottom: 1em;
        }
        .article-navigation {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #edf2f7;
        }
        .nav-link {
            background: #f8fafc;
            padding: 8px 16px;
            border-radius: 30px;
            color: #1e293b;
            text-decoration: none;
            font-size: 14px;
            transition: 0.2s;
        }
        .nav-link:hover {
            background: #ff7e00;
            color: white;
        }
        .disabled-nav {
            background: #f1f5f9;
            color: #94a3b8;
            cursor: not-allowed;
        }
        @media (max-width: 640px) {
            .article { padding: 20px; }
            .article-title { font-size: 22px; }
            .article-content { font-size: 14px; }
        }
    </style>

    <div class="detail-container">
        <a href="News.aspx" class="back-link">← 返回列表</a>
        <div class="article">
            <h1 class="article-title"><asp:Literal ID="litTitle" runat="server"></asp:Literal></h1>
            <div class="article-meta">
                <span><i class="far fa-tag"></i> <asp:Literal ID="litCategory" runat="server"></asp:Literal></span>
                <span><i class="far fa-user"></i> <asp:Literal ID="litAuthor" runat="server"></asp:Literal></span>
                <span><i class="far fa-newspaper"></i> 来源：<span class="source"><asp:Literal ID="litSource" runat="server"></asp:Literal></span></span>
                <span><i class="far fa-calendar-alt"></i> <asp:Literal ID="litDate" runat="server"></asp:Literal></span>
            </div>
            <asp:Literal ID="litContent" runat="server"></asp:Literal>
            <asp:Image ID="imgNews" runat="server" CssClass="article-img" Visible="false" />
            <div class="article-navigation">
                <asp:HyperLink ID="lnkPrev" runat="server" CssClass="nav-link" Text="上一篇" />
                <asp:HyperLink ID="lnkNext" runat="server" CssClass="nav-link" Text="下一篇" />
            </div>
        </div>
    </div>
</asp:Content>
