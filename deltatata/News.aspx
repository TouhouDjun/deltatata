<%@ Page Title="游戏资讯 - 塔科夫交易行" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="News.aspx.cs" Inherits="DeltaTradeHub.News" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .news-container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        /* 顶部标签栏 */
        .news-tabs {
            display: flex;
            gap: 12px;
            border-bottom: 2px solid #eef2f6;
            padding-bottom: 12px;
            margin-bottom: 24px;
            align-items: center;
        }
        .news-tab {
            padding: 6px 20px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            color: #64748b;
            transition: 0.2s;
        }
        .news-tab.active {
            color: #ff7e00;
            border-bottom: 2px solid #ff7e00;
            margin-bottom: -2px;
        }
        .post-btn {
            margin-left: auto;
            background: #ff7e00;
            color: white;
            border: none;
            border-radius: 40px;
            padding: 4px 16px;
            font-size: 13px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }
        /* 新闻列表 */
        .news-list {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        .news-card {
            background: white;
            border-radius: 16px;
            padding: 12px 16px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            transition: 0.2s;
            border: 1px solid #edf2f7;
            display: flex;
            align-items: center;
            gap: 16px;
            cursor: pointer;
        }
        .news-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.08);
            border-color: #ffd9b3;
        }
        /* 左侧图片 */
        .news-image {
            width: 320px;
            height: 320px;
            border-radius: 12px;
            object-fit: cover;
            flex-shrink: 0;
            background: #f8fafc;
        }
        .news-info {
            flex: 1;
        }
        .news-title {
            font-size: 16px;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 6px;
            line-height: 1.4;
        }
        .news-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 16px;
            font-size: 12px;
            color: #64748b;
        }
        .news-meta span {
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .news-source {
            color: #ff7e00;
        }
        .news-star {
            color: #ffb800;
            font-size: 18px;
            cursor: pointer;
            margin-left: 8px;
            flex-shrink: 0;
        }
        .empty-news {
            text-align: center;
            padding: 60px;
            color: #94a3b8;
        }
        @media (max-width: 640px) {
            .news-card { padding: 12px; gap: 12px; }
            .news-image { width: 48px; height: 48px; }
            .news-title { font-size: 14px; }
            .news-meta { gap: 8px; font-size: 11px; }
        }
    </style>

    <div class="news-container">
        <div class="news-tabs">
            <div class="news-tab active" data-cat="all">全部</div>
            <div class="news-tab" data-cat="CS2">CS2</div>
            <div class="news-tab" data-cat="DOTA2">DOTA2</div>
            <!-- 将按钮改为 <a> 标签，直接跳转，不依赖 JavaScript -->
            <a href="PostArticle.aspx" class="post-btn">文章投稿</a>
        </div>

        <div class="news-list">
            <asp:Repeater ID="rptNews" runat="server">
                <ItemTemplate>
                    <div class="news-card" data-cat='<%# Eval("Category") %>' data-id='<%# Eval("NewsId") %>'>
                        <img class="news-image" src='<%# Eval("ImageUrl") %>' onerror="this.src='/img/items/default.png'" />
                        <div class="news-info">
                            <div class="news-title"><%# Eval("Title") %></div>
                            <div class="news-meta">
                                <span><i class="far fa-user"></i> <%# Eval("Author") %></span>
                                <span><i class="far fa-newspaper"></i> 来源：<span class="news-source"><%# Eval("Source") %></span></span>
                                <span><i class="far fa-calendar-alt"></i> <%# Eval("PublishDate", "{0:yyyy-MM-dd}") %></span>
                            </div>
                        </div>
                        <div class="news-star" data-id='<%# Eval("NewsId") %>' onclick="toggleStar(this)">☆</div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Literal ID="litNoData" runat="server" Visible="false" Text='<div class="empty-news">暂无资讯</div>' />
        </div>
    </div>

    <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
    <script>
        // 分类筛选
        $('.news-tab').click(function () {
            $('.news-tab').removeClass('active');
            $(this).addClass('active');
            var cat = $(this).data('cat');
            if (cat === 'all') {
                $('.news-card').show();
            } else {
                $('.news-card').hide();
                $('.news-card[data-cat="' + cat + '"]').show();
            }
        });

        // 收藏星标切换（前端演示）
        window.toggleStar = function (el) {
            if ($(el).text() === '☆') {
                $(el).text('★');
                alert('已收藏（演示功能）');
            } else {
                $(el).text('☆');
            }
        };

        // 点击新闻卡片跳转详情页
        $('.news-card').click(function (e) {
            if ($(e.target).hasClass('news-star')) return;
            var newsId = $(this).data('id');
            if (newsId) {
                window.location.href = 'NewsDetail.aspx?id=' + newsId;
            }
        });
    </script>
</asp:Content>