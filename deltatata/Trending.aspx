<%@ Page Title="趋势榜单 - 塔科夫交易行" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Trending.aspx.cs" Inherits="DeltaTradeHub.Trending" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .trending-container {
            max-width: 1200px;
            margin: 24px auto;
            padding: 0 20px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            border-radius: 16px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            border: 1px solid #edf2f7;
        }
        .stat-title {
            font-size: 13px;
            color: #64748b;
            margin-bottom: 8px;
        }
        .stat-value {
            font-size: 28px;
            font-weight: 700;
            color: #1e293b;
        }
        .stat-change {
            font-size: 12px;
            margin-top: 6px;
        }
        .positive { color: #10b981; }
        .negative { color: #ef4444; }
        .chart-container {
            background: white;
            border-radius: 16px;
            padding: 20px;
            margin-bottom: 30px;
            border: 1px solid #edf2f7;
        }
        .chart-title {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 16px;
            padding-left: 8px;
            border-left: 4px solid #ff7e00;
        }
        #priceChart {
            width: 100%;
            height: 350px;
        }
        .trend-layout {
            display: flex;
            gap: 24px;
        }
        .trend-left {
            flex: 2;
        }
        .trend-right {
            flex: 1;
        }
        .rank-table {
            width: 100%;
            background: white;
            border-radius: 16px;
            border: 1px solid #edf2f7;
            overflow: hidden;
        }
        .rank-table th {
            background: #f8fafc;
            padding: 12px 16px;
            text-align: left;
            font-weight: 600;
            color: #1e293b;
            font-size: 14px;
        }
        .rank-table td {
            padding: 10px 16px;
            border-bottom: 1px solid #edf2f7;
            font-size: 14px;
        }
        .rank-number {
            width: 40px;
            color: #64748b;
        }
        .hot-item-name {
            font-weight: 500;
        }
        .more-link {
            display: block;
            text-align: center;
            padding: 8px;
            background: #f8fafc;
            border-radius: 0 0 16px 16px;
            color: #ff7e00;
            text-decoration: none;
            font-size: 13px;
        }
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: baseline;
            margin-bottom: 16px;
        }
        .section-header h3 {
            font-size: 18px;
            font-weight: 700;
        }
        @media (max-width: 768px) {
            .stats-grid { grid-template-columns: repeat(2,1fr); }
            .trend-layout { flex-direction: column; }
        }
    </style>

    <div class="trending-container">
        <!-- 顶部指标卡片 -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-title">整体价格趋势</div>
                <div class="stat-value" id="overallPrice">1,256.80</div>
                <div class="stat-change positive" id="priceChange">↑ 2.35%</div>
            </div>
            <div class="stat-card">
                <div class="stat-title">涨跌排行</div>
                <div class="stat-value" id="topCategory">突击步枪</div>
                <div class="stat-change positive" id="categoryChange">↑ 3.86%</div>
            </div>
            <div class="stat-card">
                <div class="stat-title">热销物品</div>
                <div class="stat-value" id="hotItemCount">1,284</div>
                <div class="stat-change">近7天交易量</div>
            </div>
            <div class="stat-card">
                <div class="stat-title">游戏活跃峰值</div>
                <div class="stat-value">122万</div>
                <div class="stat-change negative">比昨日 -1.54%</div>
            </div>
        </div>

        <!-- ECharts 图表 -->
        <div class="chart-container">
            <div class="chart-title">📈 近7日饰品价格趋势</div>
            <div id="priceChart"></div>
        </div>

        <div class="trend-layout">
            <!-- 左侧：分类涨跌排行 -->
            <div class="trend-left">
                <div class="section-header">
                    <h3>📊 分类涨跌排行</h3>
                    <select id="ddlSortType" class="sort-select">
                        <option value="24h" selected>24小时</option>
                        <option value="7d">7天</option>
                    </select>
                </div>
                <div id="categoryRankTable"></div>
            </div>

            <!-- 右侧：热销物品排行 -->
            <div class="trend-right">
                <div class="section-header">
                    <h3>🔥 热销物品</h3>
                </div>
                <div id="hotItemsTable"></div>
            </div>
        </div>
    </div>

    <script src="Scripts/echarts.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
    <script>
        // 模拟分类涨跌数据
        const categoriesData = {
            "24h": [
                { name: "突击步枪", change: 3.86, catId: 1 },
                { name: "匕首", change: 2.54, catId: 6 },
                { name: "手枪", change: 1.92, catId: 2 },
                { name: "手套", change: 1.45, catId: 3 },
                { name: "CS2饰品", change: 1.21, catId: 7 },
                { name: "DOTA2饰品", change: 0.88, catId: 9 },
                { name: "装备", change: 0.32, catId: 3 },
                { name: "近战武器", change: -0.15, catId: 6 },
                { name: "微型冲锋枪", change: -0.76, catId: 5 },
                { name: "霰弹枪", change: -1.23, catId: 6 },
                { name: "机枪", change: -1.98, catId: 7 },
                { name: "医疗品", change: -2.14, catId: 4 },
                { name: "配件", change: -2.76, catId: 5 },
                { name: "绝地求生饰品", change: -3.42, catId: 8 }
            ],
            "7d": [
                { name: "突击步枪", change: 5.21, catId: 1 },
                { name: "匕首", change: 4.32, catId: 6 },
                { name: "手枪", change: 3.15, catId: 2 },
                { name: "CS2饰品", change: 2.78, catId: 7 },
                { name: "手套", change: 2.11, catId: 3 },
                { name: "DOTA2饰品", change: 1.54, catId: 9 },
                { name: "装备", change: 0.65, catId: 3 },
                { name: "近战武器", change: -0.32, catId: 6 },
                { name: "微型冲锋枪", change: -1.12, catId: 5 },
                { name: "霰弹枪", change: -1.87, catId: 6 },
                { name: "机枪", change: -2.43, catId: 7 },
                { name: "医疗品", change: -3.05, catId: 4 },
                { name: "配件", change: -3.67, catId: 5 },
                { name: "绝地求生饰品", change: -4.21, catId: 8 }
            ]
        };

        // 模拟热销物品数据
        const hotItemsData = [
            { name: "AK-47 | 皇后", count: 342 },
            { name: "M4A4 | 龙王", count: 287 },
            { name: "蝴蝶刀 | 多普勒", count: 256 },
            { name: "AWP | 二西莫夫", count: 198 },
            { name: "沙漠之鹰 | 红色代号", count: 167 },
            { name: "爪子刀 | 黑色魅影", count: 145 },
            { name: "格洛克18 | 摩登时代", count: 132 },
            { name: "USP-S | 印花集", count: 118 },
            { name: "AK-47 | 血腥运动", count: 105 },
            { name: "M4A1-S | 印花集", count: 94 }
        ];

        // 模拟价格趋势数据（近7天）
        const priceTrendDays = ["05-09", "05-10", "05-11", "05-12", "05-13", "05-14", "05-15"];
        const priceTrendValues = [1250.5, 1248.2, 1253.6, 1260.1, 1258.4, 1265.8, 1272.3];

        // 渲染分类涨跌排行榜
        function renderCategoryRank(period) {
            const data = categoriesData[period];
            let html = `<table class="rank-table">
                            <thead><tr><th>分类</th><th>趋势</th><th>价格变化</th><th>操作</th></tr></thead>
                            <tbody>`;
            data.forEach(item => {
                const isPositive = item.change >= 0;
                const arrow = isPositive ? "↑" : "↓";
                const changeClass = isPositive ? "positive" : "negative";
                html += `<tr>
                            <td>${item.name}</td>
                            <td><span class="${changeClass}">${arrow}</span></td>
                            <td class="${changeClass}">${Math.abs(item.change).toFixed(2)}%</td>
                            <td><a href="Marketplace.aspx?cat=${item.catId}" class="more-link" style="display:inline-block; padding:2px 12px;">详情</a></td>
                          </tr>`;
            });
            html += `</tbody></table>`;
            $("#categoryRankTable").html(html);
        }

        // 渲染热销物品排行榜
        function renderHotItems() {
            let html = `<table class="rank-table">
                            <thead><tr><th>排名</th><th>物品</th><th>交易量</th></tr></thead>
                            <tbody>`;
            hotItemsData.forEach((item, index) => {
                html += `<tr>
                            <td class="rank-number">${index + 1}</td>
                            <td class="hot-item-name">${item.name}</td>
                            <td>${item.count} 笔</td>
                          </tr>`;
            });
            html += `</tbody></table><a href="Marketplace.aspx" class="more-link">查看更多 &gt;</a>`;
            $("#hotItemsTable").html(html);
        }

        // 绘制价格趋势图
        function drawChart() {
            var chart = echarts.init(document.getElementById('priceChart'));
            chart.setOption({
                tooltip: { trigger: 'axis' },
                xAxis: { type: 'category', data: priceTrendDays, axisLabel: { rotate: 30 } },
                yAxis: { type: 'value', name: '均价 (¥)' },
                series: [{
                    data: priceTrendValues,
                    type: 'line',
                    smooth: true,
                    lineStyle: { color: '#ff7e00', width: 3 },
                    areaStyle: { opacity: 0.1, color: '#ff7e00' },
                    symbol: 'circle',
                    symbolSize: 6
                }],
                grid: { containLabel: true, left: 50 }
            });
        }

        // 初始化
        $(function () {
            renderCategoryRank("24h");
            renderHotItems();
            drawChart();

            $("#ddlSortType").change(function () {
                const period = $(this).val();
                renderCategoryRank(period);
            });
        });
    </script>
</asp:Content>