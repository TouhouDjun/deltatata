<%@ Page Title="仪表盘" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="DeltaTradeHub.AdminDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="PageTitle" runat="server">
    仪表盘 - 管理后台
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .dashboard-stats {
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
        .stat-number {
            font-size: 28px;
            font-weight: 700;
            color: #ff7e00;
        }
        .stat-label {
            font-size: 14px;
            color: #64748b;
            margin-top: 6px;
        }
        .chart-row {
            display: flex;
            gap: 24px;
            margin-bottom: 30px;
        }
        .chart-box {
            flex: 1;
            background: white;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            border: 1px solid #edf2f7;
        }
        .chart-title {
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 16px;
            padding-left: 8px;
            border-left: 4px solid #ff7e00;
        }
        .chart-container {
            width: 100%;
            height: 300px;
        }
        .full-width {
            width: 100%;
            margin-top: 20px;
        }
        @media (max-width: 768px) {
            .chart-row { flex-direction: column; }
            .dashboard-stats { grid-template-columns: repeat(2,1fr); }
        }
    </style>

    <!-- 统计卡片（数据来自后台） -->
    <div class="dashboard-stats">
        <div class="stat-card">
            <div class="stat-number"><asp:Literal ID="litTotalUsers" runat="server">--</asp:Literal></div>
            <div class="stat-label">总用户数</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><asp:Literal ID="litTodayOrders" runat="server">--</asp:Literal></div>
            <div class="stat-label">今日订单</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">¥ <asp:Literal ID="litTodayTurnover" runat="server">--</asp:Literal></div>
            <div class="stat-label">今日交易额</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><asp:Literal ID="litPendingRecharge" runat="server">--</asp:Literal></div>
            <div class="stat-label">待审核充值</div>
        </div>
    </div>

    <!-- 两个饼图并排（保持模拟数据） -->
    <div class="chart-row">
        <div class="chart-box">
            <div class="chart-title">📊 商品分类占比</div>
            <div id="pieChartCategory" class="chart-container"></div>
        </div>
        <div class="chart-box">
            <div class="chart-title">💰 订单状态占比</div>
            <div id="pieChartOrderStatus" class="chart-container"></div>
        </div>
    </div>

    <!-- 热力图（保持模拟数据） -->
    <div class="chart-box full-width">
        <div class="chart-title">🔥 用户活跃热力图（按小时/星期）</div>
        <div id="heatmapChart" class="chart-container" style="height: 360px;"></div>
    </div>

    <script src="Scripts/echarts.js"></script>
    <script>
        // 1. 商品分类占比饼图（模拟数据）
        var categoryChart = echarts.init(document.getElementById('pieChartCategory'));
        categoryChart.setOption({
            tooltip: { trigger: 'item', formatter: '{b}: {d}%' },
            legend: { orient: 'vertical', left: 'left', data: ['突击步枪', '手枪', '匕首', '手套', '冲锋枪', '其他'] },
            series: [{
                type: 'pie',
                radius: '55%',
                center: ['50%', '60%'],
                data: [
                    { name: '突击步枪', value: 342, itemStyle: { color: '#ff7e00' } },
                    { name: '手枪', value: 287, itemStyle: { color: '#f59e0b' } },
                    { name: '匕首', value: 198, itemStyle: { color: '#10b981' } },
                    { name: '手套', value: 156, itemStyle: { color: '#3b82f6' } },
                    { name: '冲锋枪', value: 98, itemStyle: { color: '#8b5cf6' } },
                    { name: '其他', value: 123, itemStyle: { color: '#94a3b8' } }
                ],
                label: { show: true, formatter: '{b}: {d}%' },
                emphasis: { scale: true }
            }]
        });

        // 2. 订单状态占比饼图（模拟数据）
        var orderStatusChart = echarts.init(document.getElementById('pieChartOrderStatus'));
        orderStatusChart.setOption({
            tooltip: { trigger: 'item', formatter: '{b}: {d}%' },
            legend: { orient: 'vertical', left: 'left', data: ['已完成', '待支付', '已取消', '已发货'] },
            series: [{
                type: 'pie',
                radius: '55%',
                center: ['50%', '60%'],
                data: [
                    { name: '已完成', value: 1256, itemStyle: { color: '#10b981' } },
                    { name: '待支付', value: 342, itemStyle: { color: '#f59e0b' } },
                    { name: '已取消', value: 87, itemStyle: { color: '#ef4444' } },
                    { name: '已发货', value: 213, itemStyle: { color: '#3b82f6' } }
                ],
                label: { show: true, formatter: '{b}: {d}%' }
            }]
        });

        // 3. 热力图（模拟一周七天×24小时的活跃度数据）
        var hours = [];
        for (var i = 0; i < 24; i++) hours.push(i + ':00');
        var days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
        var heatData = [];
        for (var day = 0; day < 7; day++) {
            for (var hour = 0; hour < 24; hour++) {
                var base = (hour >= 9 && hour <= 22) ? 60 : 20;
                if (day >= 5) base += 30;
                var random = Math.floor(Math.random() * 40);
                var value = base + random;
                heatData.push([hour, day, value]);
            }
        }

        var heatmapChart = echarts.init(document.getElementById('heatmapChart'));
        heatmapChart.setOption({
            tooltip: {
                position: 'top', formatter: function (params) {
                    return days[params.value[1]] + ' ' + hours[params.value[0]] + '<br/>活跃值: ' + params.value[2];
                }
            },
            xAxis: { type: 'category', data: hours, name: '小时', splitArea: { show: true } },
            yAxis: { type: 'category', data: days, name: '星期', splitArea: { show: true } },
            visualMap: {
                min: 0, max: 120, calculable: true, orient: 'horizontal', left: 'center',
                inRange: { color: ['#e0f2fe', '#7dd3fc', '#38bdf8', '#0ea5e9', '#0284c7', '#0369a1'] }
            },
            series: [{ name: '活跃度', type: 'heatmap', data: heatData, label: { show: false }, emphasis: { itemStyle: { shadowBlur: 10 } } }]
        });
    </script>
</asp:Content>